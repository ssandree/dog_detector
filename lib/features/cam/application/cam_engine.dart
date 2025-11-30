// lib/features/cam/application/cam_engine.dart

import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../webrtc/data/webrtc_api_service.dart';

class CamStreamingState {
  final bool connected;
  final bool connecting;
  final String camId;
  final String viewerId;

  final bool hasLocalStream;
  final String? sessionId;
  final String? errorMessage;

  const CamStreamingState({
    required this.connected,
    required this.connecting,
    required this.camId,
    required this.viewerId,
    this.hasLocalStream = false,
    this.sessionId,
    this.errorMessage,
  });

  static const initial = CamStreamingState(
    connected: false,
    connecting: false,
    camId: '',
    viewerId: '',
    hasLocalStream: false,
    sessionId: null,
    errorMessage: null,
  );

  CamStreamingState copyWith({
    bool? connected,
    bool? connecting,
    String? camId,
    String? viewerId,
    bool? hasLocalStream,
    String? sessionId,
    String? errorMessage,
  }) {
    return CamStreamingState(
      connected: connected ?? this.connected,
      connecting: connecting ?? this.connecting,
      camId: camId ?? this.camId,
      viewerId: viewerId ?? this.viewerId,
      hasLocalStream: hasLocalStream ?? this.hasLocalStream,
      sessionId: sessionId ?? this.sessionId,
      errorMessage: errorMessage,
    );
  }
}

class CamEngine extends AsyncNotifier<CamStreamingState> {
  WebRtcApiService get _api => ref.read(webrtcApiServiceProvider);

  RTCPeerConnection? _pc;
  MediaStream? _localStream;

  Timer? _answerTimer;
  Timer? _candidateTimer;

  bool _disposed = false;

  @override
  CamStreamingState build() {
    ref.onDispose(_disposeInternal);
    return CamStreamingState.initial;
  }

  Future<void> _disposeInternal() async {
    _disposed = true;
    _answerTimer?.cancel();
    _candidateTimer?.cancel();
    _answerTimer = null;
    _candidateTimer = null;

    try {
      await _pc?.close();
    } catch (_) {}
    _pc = null;

    try {
      await _localStream?.dispose();
    } catch (_) {}
    _localStream = null;
  }

  void setDeviceIds(String camId, String viewerId) {
    final current = state.value ?? CamStreamingState.initial;
    state = AsyncValue.data(
      current.copyWith(
        camId: camId,
        viewerId: viewerId,
        errorMessage: null,
      ),
    );
  }

  Future<void> startStreaming() async {
    final current = state.value ?? CamStreamingState.initial;

    if (current.camId.isEmpty || current.viewerId.isEmpty) {
      state = AsyncValue.data(
        current.copyWith(
          errorMessage: 'camId / viewerId 가 설정되지 않았습니다.',
          connected: false,
          connecting: false,
        ),
      );
      return;
    }

    if (current.connecting || current.connected) return;

    state = AsyncValue.data(
      current.copyWith(
        connecting: true,
        connected: false,
        errorMessage: null,
      ),
    );

    try {
      final localStream = await navigator.mediaDevices.getUserMedia({
        'video': {
          'facingMode': 'environment',
        },
        'audio': false,
      });
      _localStream = localStream;

      final config = await _api.fetchConfig();
      final pcConfig = config.toPeerConnectionConfig();
      final pc = await createPeerConnection(pcConfig);
      _pc = pc;

      for (final track in localStream.getTracks()) {
        await pc.addTrack(track, localStream);
      }

      pc.onIceCandidate = (RTCIceCandidate c) async {
        if (c.candidate == null) return;
        final s = state.value ?? CamStreamingState.initial;
        if (s.sessionId == null) return;

        try {
          await _api.sendCandidate(
            sessionId: s.sessionId!,
            senderDeviceId: s.camId,
            receiverDeviceId: s.viewerId,
            candidate: c.candidate!,
          );
        } catch (_) {
        }
      };

      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);

      final sessionId = await _api.sendOffer(
        senderDeviceId: current.camId,
        receiverDeviceId: current.viewerId,
        sdpOffer: offer.sdp ?? '',
      );

      state = AsyncValue.data(
        (state.value ?? CamStreamingState.initial).copyWith(
          sessionId: sessionId,
          hasLocalStream: true,
        ),
      );

      _startAnswerPolling();

      _startCandidatePolling();
    } catch (e) {
      state = AsyncValue.data(
        (state.value ?? CamStreamingState.initial).copyWith(
          connecting: false,
          connected: false,
          errorMessage: 'CAM WebRTC 시작 실패: $e',
        ),
      );
      await _disposeInternal();
    }
  }

  Future<void> stopStreaming() async {
    await _disposeInternal();
    final current = state.value ?? CamStreamingState.initial;

    state = AsyncValue.data(
      current.copyWith(
        connected: false,
        connecting: false,
        hasLocalStream: false,
        sessionId: null,
        errorMessage: null,
      ),
    );
  }

  void _startAnswerPolling() {
    _answerTimer?.cancel();
    _answerTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_disposed) return;
      final s = state.value ?? CamStreamingState.initial;
      if (s.sessionId == null) return;

      try {
        final answerSdp =
            await _api.fetchAnswer(sessionId: s.sessionId!);
        if (answerSdp == null) return;

        final desc = RTCSessionDescription(answerSdp, 'answer');
        await _pc?.setRemoteDescription(desc);

        state = AsyncValue.data(
          (state.value ?? CamStreamingState.initial).copyWith(
            connecting: false,
            connected: true,
            errorMessage: null,
          ),
        );

        _answerTimer?.cancel();
        _answerTimer = null;
      } catch (e) {
      }
    });
  }

  void _startCandidatePolling() {
    _candidateTimer?.cancel();
    _candidateTimer =
        Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_disposed) return;
      final s = state.value ?? CamStreamingState.initial;
      if (s.sessionId == null) return;

      try {
        final list = await _api.fetchCandidates(
          sessionId: s.sessionId!,
          deviceId: s.camId,
        );

        for (final c in list) {
          await _pc?.addCandidate(
            RTCIceCandidate(c, '0', 0),
          );
        }
      } catch (e) {
      }
    });
  }
}

final camEngineProvider =
    AsyncNotifierProvider<CamEngine, CamStreamingState>(CamEngine.new);
