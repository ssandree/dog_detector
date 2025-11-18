import 'home_service.dart';

/// Remote 홈 서비스 구현체
/// 실제 API 호출하는 구현체
class RemoteHomeService implements HomeService {
  @override
  Future<List<Map<String, dynamic>>> getEmotionData() {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getAIRecommendations() {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getWeatherData() {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getRecentDetection() {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentEmotionTags() {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentVideos({int limit = 5}) {
    throw UnimplementedError();
  }
}

