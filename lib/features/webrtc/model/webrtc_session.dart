// lib/features/webrtc/model/webrtc_session.dart

class WebRtcSessionInfo {
  final String? sessionId;
  final String senderDeviceId;
  final String receiverDeviceId;

  WebRtcSessionInfo({
    required this.sessionId,
    required this.senderDeviceId,
    required this.receiverDeviceId,
  });

  factory WebRtcSessionInfo.fromJson(Map<String, dynamic> json) {
    return WebRtcSessionInfo(
      sessionId: json['session_id'] as String?,
      senderDeviceId: json['sender_device_id'] as String? ?? '',
      receiverDeviceId: json['receiver_device_id'] as String? ?? '',
    );
  }
}
