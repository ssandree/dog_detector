// lib/features/realtime/infrastructure/viewer_engine.dart

import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../webrtc/data/webrtc_api_service.dart';
import '../../webrtc/model/webrtc_session.dart';

final viewerEngineProvider = Provider<ViewerEngine>((ref) {
  final api = ref.read(webrtcApiServiceProvider);
  return ViewerEngine(api);
});

class ViewerEngine {
  final WebRtcApiService _api;

  RTCPeerConnection? _pc;
  RTCVideoRenderer? _renderer;

  bool _disposed = false;
  Timer? _candidateTimer;
  String? _sessionId;

  ViewerEngine(this._api);

  Future<RTCVideoRenderer> startViewing({
    required String cameraDeviceId,
    required String viewerDeviceId,
  }) async {
    _disposed = false;
    _sessionId = null;

    WebRtcSessionInfo? latest;
    while (true) {
      latest = await _api.fetchLatestSession(deviceId: cameraDeviceId);
      if (latest?.sessionId != null) break;
      await Future.delayed(const Duration(seconds: 1));
    }

    _sessionId = latest!.sessionId;

    final config = await _api.fetchConfig();
    final pcConfig = config.toPeerConnectionConfig();
    final pc = await createPeerConnection(pcConfig);
    _pc = pc;

    final renderer = RTCVideoRenderer();
    await renderer.initialize();
    _renderer = renderer;

    pc.onTrack = (ev) {
      if (ev.streams.isNotEmpty) renderer.srcObject = ev.streams.first;
    };

    pc.onAddStream = (stream) {
      renderer.srcObject = stream;
    };

    pc.onIceCandidate = (c) async {
      if (_sessionId == null || c.candidate == null) return;
      await _api.sendCandidate(
        sessionId: _sessionId!,
        senderDeviceId: viewerDeviceId,
        receiverDeviceId: cameraDeviceId,
        candidate: c.candidate!,
      );
    };

    await _waitOffer(_sessionId!);

    final answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);
    await _api.sendAnswer(
      sessionId: _sessionId!,
      sdpAnswer: answer.sdp ?? '',
    );

    _startCandidatePolling(
      sessionId: _sessionId!,
      deviceId: viewerDeviceId,
    );

    return renderer;
  }

  Future<void> _waitOffer(String sessionId) async {
    while (!_disposed) {
      await Future.delayed(const Duration(seconds: 1));
      final offer = await _api.fetchOffer(sessionId: sessionId);
      if (offer == null) continue;

      final desc = RTCSessionDescription(offer, 'offer');
      await _pc?.setRemoteDescription(desc);
      break;
    }
  }

  void _startCandidatePolling({
    required String sessionId,
    required String deviceId,
  }) {
    _candidateTimer?.cancel();
    _candidateTimer =
        Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_disposed) return;
      final list = await _api.fetchCandidates(
        sessionId: sessionId,
        deviceId: deviceId,
      );
      for (final c in list) {
        await _pc?.addCandidate(
          RTCIceCandidate(c, '0', 0),
        );
      }
    });
  }

  Future<void> stop() async {
    _disposed = true;
    _candidateTimer?.cancel();
    _candidateTimer = null;

    try {
      await _pc?.close();
    } catch (_) {}
    _pc = null;

    try {
      await _renderer?.dispose();
    } catch (_) {}
    _renderer = null;

    _sessionId = null;
  }
}
