import '../../../data/pet_mock.dart';
import '../../exceptions.dart';
import 'home_service.dart';

/// Mock 홈 서비스 구현체
/// API 없이도 동작하는 가짜 구현체
class MockHomeService implements HomeService {
  @override
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

  @override
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

  @override
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

  @override
  Future<Map<String, dynamic>> getRecentDetection() async {
    try {
      // TODO: 실제 API 호출로 변경
      await Future.delayed(const Duration(milliseconds: 200));
      return Map<String, dynamic>.from(mockRecentDetection);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('최근 감지 데이터를 불러오는데 실패했습니다', e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentEmotionTags() async {
    try {
      // TODO: 실제 API 호출로 변경
      await Future.delayed(const Duration(milliseconds: 200));
      return List<Map<String, dynamic>>.from(mockRecentEmotionTags);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('최근 감정 태그를 불러오는데 실패했습니다', e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentVideos({int limit = 5}) async {
    try {
      // TODO: 실제 API 호출로 변경
      await Future.delayed(const Duration(milliseconds: 300));
      return List<Map<String, dynamic>>.from(mockRecentVideos.take(limit));
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('최근 영상 목록을 불러오는데 실패했습니다', e);
    }
  }
}

