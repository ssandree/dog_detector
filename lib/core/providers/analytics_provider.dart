// lib/core/providers/analytics_provider.dart
// 분석 리포트 상태 관리 Provider
// - AnalyticsRepository를 통해 API/캐시 접근
// - Notifier 기반 상태 관리
// - 일/주/월 탭 전환 상태 포함

import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../models/analytics_bundle.dart';
import '../repositories/analytics_repository.dart';

// 리포트 기간 구분용 enum
enum ReportPeriod { daily, weekly, monthly }

// 선택된 리포트 기간 상태 관리용 Notifier
class SelectedPeriodNotifier extends Notifier<ReportPeriod> {
  @override
  ReportPeriod build() => ReportPeriod.daily;

  void setPeriod(ReportPeriod value) => state = value;
}

final selectedPeriodProvider =
    NotifierProvider<SelectedPeriodNotifier, ReportPeriod>(
        SelectedPeriodNotifier.new);

// 분석 데이터 컨트롤러
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

// 분석 리포트 Provider
final analyticsProvider =
    AsyncNotifierProvider<AnalyticsController, AnalyticsBundle?>(
        AnalyticsController.new);
