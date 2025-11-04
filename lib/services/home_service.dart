import '../data/pet_mock.dart';
import '../core/exceptions.dart';

/// 홈 화면 관련 데이터 서비스
class HomeService {
  /// 최근 24시간 감정 분석 데이터 조회
  Future<List<Map<String, dynamic>>> getEmotionData() async {
    try {
      // TODO: 실제 API 호출로 변경
      await Future.delayed(const Duration(milliseconds: 300)); // 로딩 시뮬레이션
      return List<Map<String, dynamic>>.from(mockEmotionData);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('감정 분석 데이터를 불러오는데 실패했습니다', e);
    }
  }

  /// AI 추천 액션 데이터 조회
  Future<List<Map<String, dynamic>>> getAIRecommendations() async {
    try {
      // TODO: 실제 API 호출로 변경
      await Future.delayed(const Duration(milliseconds: 300)); // 로딩 시뮬레이션
      return List<Map<String, dynamic>>.from(mockAIRecommendations);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('AI 추천 데이터를 불러오는데 실패했습니다', e);
    }
  }

  /// 날씨 데이터 조회
  Future<List<Map<String, dynamic>>> getWeatherData() async {
    try {
      // TODO: 실제 API 호출로 변경
      await Future.delayed(const Duration(milliseconds: 300)); // 로딩 시뮬레이션
      return List<Map<String, dynamic>>.from(mockWeatherData);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('날씨 데이터를 불러오는데 실패했습니다', e);
    }
  }
}

