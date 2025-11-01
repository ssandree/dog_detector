import '../data/pet_mock.dart';

/// 홈 화면 관련 데이터 서비스
class HomeService {
  /// 최근 24시간 감정 분석 데이터 조회
  static Future<List<Map<String, dynamic>>> getEmotionData() async {
    // TODO: 실제 API 호출로 변경
    await Future.delayed(const Duration(milliseconds: 300)); // 로딩 시뮬레이션
    return List<Map<String, dynamic>>.from(mockEmotionData);
  }

  /// AI 추천 액션 데이터 조회
  static Future<List<Map<String, dynamic>>> getAIRecommendations() async {
    // TODO: 실제 API 호출로 변경
    await Future.delayed(const Duration(milliseconds: 300)); // 로딩 시뮬레이션
    return List<Map<String, dynamic>>.from(mockAIRecommendations);
  }

  /// 날씨 데이터 조회
  static Future<List<Map<String, dynamic>>> getWeatherData() async {
    // TODO: 실제 API 호출로 변경
    await Future.delayed(const Duration(milliseconds: 300)); // 로딩 시뮬레이션
    return List<Map<String, dynamic>>.from(mockWeatherData);
  }
}

