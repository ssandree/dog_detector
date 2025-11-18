import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/home/home_service.dart';
import '../services/home/mock_home_service.dart';

/// HomeService Provider
final homeServiceProvider = Provider<HomeService>((ref) {
  return MockHomeService();
});

/// 감정 분석 데이터 상태를 관리하는 Provider
final emotionDataProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final homeService = ref.watch(homeServiceProvider);
  return await homeService.getEmotionData();
});

/// AI 추천 액션 데이터 상태를 관리하는 Provider
final aiRecommendationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final homeService = ref.watch(homeServiceProvider);
  return await homeService.getAIRecommendations();
});

/// 날씨 데이터 상태를 관리하는 Provider
final weatherDataProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final homeService = ref.watch(homeServiceProvider);
  return await homeService.getWeatherData();
});

/// 최근 감지 시간 상태를 관리하는 Provider
final recentDetectionProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final homeService = ref.watch(homeServiceProvider);
  return await homeService.getRecentDetection();
});

/// 최근 감지된 감정 태그 상태를 관리하는 Provider
final recentEmotionTagsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final homeService = ref.watch(homeServiceProvider);
  return await homeService.getRecentEmotionTags();
});

/// 최근 영상 목록 상태를 관리하는 Provider
final recentVideosProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final homeService = ref.watch(homeServiceProvider);
  return await homeService.getRecentVideos(limit: 5);
});

