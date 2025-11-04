// lib/core/repositories/analytics_repository.dart
// 분석 리포트 Repository 계층
// - AnalyticsService와 AnalyticsCache를 묶어 단일 접근 지점 제공
// - API ↔ Cache ↔ Provider 간 데이터 흐름 통합 관리

import '../services/analytics_service.dart';
import '../../local/analytics_cache.dart';
import '../../models/analytics_bundle.dart';

class AnalyticsRepository {
  final _service = AnalyticsService.instance;

  // 원격 데이터 전체 요청
  Future<AnalyticsBundle> fetchRemote() async {
    final summary = await _service.fetchSummary();
    final trend = await _service.fetchTrend();
    final camera = await _service.fetchCamera();
    return AnalyticsBundle(summary: summary, trend: trend, camera: camera);
  }

  // 캐시 로드
  Future<AnalyticsBundle?> loadCache() async {
    return await AnalyticsCache.loadBundle();
  }

  // 캐시 저장
  Future<void> saveCache(AnalyticsBundle bundle) async {
    await AnalyticsCache.saveBundle(bundle);
  }

  // 캐시 초기화
  Future<void> clearCache() async {
    await AnalyticsCache.clear();
  }
}
