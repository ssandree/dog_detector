// lib/core/providers/analytics_provider.dart
// 분석 리포트 상태 관리 Provider
// - AnalyticsRepository를 통해 API/캐시 접근
// - Riverpod AsyncNotifier로 상태 관리

import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../models/analytics_bundle.dart';
import '../repositories/analytics_repository.dart';

class AnalyticsController extends AsyncNotifier<AnalyticsBundle?> {
  final repo = AnalyticsRepository();

  @override
  Future<AnalyticsBundle?> build() async {
    final cache = await repo.loadCache();
    return cache;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final data = await repo.fetchRemote();
      await repo.saveCache(data);
      state = AsyncData(data);
    } catch (e, _) {
      final cached = await repo.loadCache();
      if (cached != null) {
        state = AsyncData(cached);
      } else {
        state = AsyncError(e, StackTrace.current);
      }
    }
  }
}

final analyticsProvider =
    AsyncNotifierProvider<AnalyticsController, AnalyticsBundle?>(
        AnalyticsController.new);
