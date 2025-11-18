/// 홈 화면 관련 데이터 서비스 인터페이스
abstract class HomeService {
  /// 최근 24시간 감정 분석 데이터 조회
  Future<List<Map<String, dynamic>>> getEmotionData();

  /// AI 추천 액션 데이터 조회
  Future<List<Map<String, dynamic>>> getAIRecommendations();

  /// 날씨 데이터 조회
  Future<List<Map<String, dynamic>>> getWeatherData();

  /// 최근 감지 시간 조회
  Future<Map<String, dynamic>> getRecentDetection();

  /// 최근 감지된 감정 태그 조회 (최근 3개)
  Future<List<Map<String, dynamic>>> getRecentEmotionTags();

  /// 최근 영상 목록 조회
  Future<List<Map<String, dynamic>>> getRecentVideos({int limit = 5});
}

