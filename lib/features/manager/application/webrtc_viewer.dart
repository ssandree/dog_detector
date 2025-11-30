// lib/features/manager/application/webrtc_viewer.dart

import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../webrtc/data/webrtc_api_service.dart';

class ManagerViewerState {
  final bool connecting;
  final bool connected;
  final String? errorMessage;
  final String? activeSessionId;
  final String? activeDeviceId;

  const ManagerViewerState({
    this.connecting = false,
    this.connected = false,
    this.errorMessage,
    this.activeSessionId,
    this.activeDeviceId,
  });

  ManagerViewerState copyWith({
    bool? connecting,
    bool? connected,
    String? errorMessage,
    String? activeSessionId,
    String? activeDeviceId,
  }) {
    return ManagerViewerState(
      connecting: connecting ?? this.connecting,
      connected: connected ?? this.connected,
      errorMessage: errorMessage,
      activeSessionId: activeSessionId ?? this.activeSessionId,
      activeDeviceId: activeDeviceId ?? this.activeDeviceId,
    );
  }

  const ManagerViewerState.initial() : this();
}

class WebRtcViewer extends AsyncNotifier<ManagerViewerState> {
  static const String _managerDeviceId = 'manager_device_1';

  WebRtcApiService get _api => ref.read(webrtcApiServiceProvider);

  RTCPeerConnection? _pc;
  String? _sessionId;
  String? _currentCamDeviceId;
  bool _disposed = false;

  @override
  ManagerViewerState build() {
    ref.onDispose(() async {
      _disposed = true;
      _sessionId = null;
      _currentCamDeviceId = null;
      try {
        await _pc?.close();
      } catch (_) {}
      _pc = null;
    });

    return const ManagerViewerState.initial();
  }

  Future<void> stopViewing() async {
    _sessionId = null;
    _currentCamDeviceId = null;
    try {
      await _pc?.close();
    } catch (_) {}
    _pc = null;

    state = AsyncData(
      state.value!.copyWith(
        connecting: false,
        connected: false,
        errorMessage: null,
        activeSessionId: null,
        activeDeviceId: null,
      ),
    );
  }

  Future<void> connectToCamera({
    required String camDeviceId,
    required RTCVideoRenderer remoteRenderer,
  }) async {
    if (_disposed) return;

    await stopViewing();

    state = AsyncData(
      state.value!.copyWith(
        connecting: true,
        connected: false,
        errorMessage: null,
        activeDeviceId: camDeviceId,
      ),
    );

    try {
      _currentCamDeviceId = camDeviceId;

      final sessionInfo =
          await _api.fetchLatestSession(deviceId: camDeviceId);

      if (sessionInfo == null || sessionInfo.sessionId == null) {
        state = AsyncData(
          state.value!.copyWith(
            connecting: false,
            connected: false,
            errorMessage: '현재 연결 가능한 세션이 없습니다.',
            activeSessionId: null,
          ),
        );
        return;
      }

      _sessionId = sessionInfo.sessionId;

      await _startViewingInternal(
        sessionId: _sessionId!,
        remoteRenderer: remoteRenderer,
      );
    } catch (e) {
      state = AsyncData(
        state.value!.copyWith(
          connecting: false,
          connected: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _startViewingInternal({
    required String sessionId,
    required RTCVideoRenderer remoteRenderer,
  }) async {
    if (_disposed) return;

    try {
      final cfg = await _api.fetchConfig();
      final pcConfig = cfg.toPeerConnectionConfig();

      final pc = await createPeerConnection(pcConfig);
      _pc = pc;

      pc.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          remoteRenderer.srcObject = event.streams.first;
        }
      };

      pc.onAddStream = (MediaStream stream) {
        remoteRenderer.srcObject = stream;
      };

      pc.onIceCandidate = (RTCIceCandidate c) {
        if (_sessionId == null || c.candidate == null) return;
        _api.sendCandidate(
          sessionId: _sessionId!,
          senderDeviceId: _managerDeviceId,
          receiverDeviceId: _currentCamDeviceId ?? '',
          candidate: c.candidate!,
        );
      };

      await _waitAndSetOffer();

      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);

      await _api.sendAnswer(
        sessionId: _sessionId!,
        sdpAnswer: answer.sdp!,
      );

      _pollCandidates();

      state = AsyncData(
        state.value!.copyWith(
          connecting: false,
          connected: true,
          errorMessage: null,
          activeSessionId: _sessionId,
        ),
      );
    } catch (e) {
      state = AsyncData(
        state.value!.copyWith(
          connecting: false,
          connected: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _waitAndSetOffer() async {
    if (_sessionId == null) return;

    while (!_disposed && _sessionId != null) {
      await Future.delayed(const Duration(seconds: 1));

      final offerSdp = await _api.fetchOffer(sessionId: _sessionId!);
      if (offerSdp == null) continue;

      final offer = RTCSessionDescription(offerSdp, 'offer');
      await _pc?.setRemoteDescription(offer);
      break;
    }
  }

  Future<void> _pollCandidates() async {
    if (_sessionId == null) return;

    while (!_disposed && _sessionId != null) {
      await Future.delayed(const Duration(seconds: 1));

      final list = await _api.fetchCandidates(
        sessionId: _sessionId!,
        deviceId: _managerDeviceId,
      );

      for (final c in list) {
        await _pc?.addCandidate(
          RTCIceCandidate(c, '0', 0),
        );
      }
    }
  }
}

final webrtcViewerProvider =
    AsyncNotifierProvider<WebRtcViewer, ManagerViewerState>(
  WebRtcViewer.new,
);
