// lib/features/realtime/domain/camera_session.dart

import 'package:flutter_webrtc/flutter_webrtc.dart';

class CameraSession {
  final String sessionId;
  final int cameraDeviceId;
  final RTCVideoRenderer renderer;

  const CameraSession({
    required this.sessionId,
    required this.cameraDeviceId,
    required this.renderer,
  });

  CameraSession copyWith({
    String? sessionId,
    int? cameraDeviceId,
    RTCVideoRenderer? renderer,
  }) {
    return CameraSession(
      sessionId: sessionId ?? this.sessionId,
      cameraDeviceId: cameraDeviceId ?? this.cameraDeviceId,
      renderer: renderer ?? this.renderer,
    );
  }
}
