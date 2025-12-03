// lib/core/network/api_endpoints.dart

class ApiEndpoints {
  static const String mainBaseUrl = "http://54.206.79.248:8000";

  static const String inferenceBaseUrl = "http://dog-det.ddns.net:8000";

  static const String login = "$mainBaseUrl/token";
  static const String signup = "$mainBaseUrl/users/";

  static const String uploadEvent = "$mainBaseUrl/events/upload";

  static const String createReport = "$mainBaseUrl/reports/create";
  static const String getReports = "$mainBaseUrl/reports";

  static const String webrtcConfig = "$mainBaseUrl/webrtc/config";
  static const String webrtcOffer = "$mainBaseUrl/stream/offer";
  static const String webrtcAnswer = "$mainBaseUrl/stream/answer";
  static const String webrtcCandidate = "$mainBaseUrl/stream/candidate";
  static const String webrtcCandidates = "$mainBaseUrl/stream/candidates";
  static const String webrtcAttachViewer =
      "$mainBaseUrl/stream/session/attach-viewer";

  static const String detectRealtime = "$inferenceBaseUrl/api/detect-realtime";
}
