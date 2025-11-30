// lib/core/network/api_endpoints.dart

class ApiEndpoints {
  static const String baseUrl = "http://54.206.79.248:8000";

  static const String login = "$baseUrl/token";
  static const String signup = "$baseUrl/users/";

  static const String detectRealtime = "$baseUrl/api/detect-realtime";

  static const String uploadEvent = "$baseUrl/events/upload";

  static const String createReport = "$baseUrl/reports/create";
  static const String getReports = "$baseUrl/reports";

  static const String webrtcConfig = "$baseUrl/webrtc/config";
  static const String webrtcOffer = "$baseUrl/stream/offer";
  static const String webrtcAnswer = "$baseUrl/stream/answer";
  static const String webrtcCandidate = "$baseUrl/stream/candidate";
  static const String webrtcCandidates = "$baseUrl/stream/candidates";
  static const String webrtcAttachViewer = "$baseUrl/stream/session/attach-viewer";
}
