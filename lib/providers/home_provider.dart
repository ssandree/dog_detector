import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/home_service.dart';

/// HomeService Provider
final homeServiceProvider = Provider<HomeService>((ref) {
  return HomeService();
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

