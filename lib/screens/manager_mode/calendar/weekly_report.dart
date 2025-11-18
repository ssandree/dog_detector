import '../../../core/index_export.dart';
import '../../../widgets/app_error_banner.dart';
import 'report_widgets/report_widgets.dart';

class WeeklyReport extends ConsumerWidget {
  const WeeklyReport({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedWeekStart = ref.watch(weeklyReportDateProvider);
    final weeklyReportAsync = ref.watch(weeklyReportProvider(selectedWeekStart));

    return AsyncValueWidget<Map<String, dynamic>>(
      asyncValue: weeklyReportAsync,
      onRetry: () => ref.invalidate(weeklyReportProvider(selectedWeekStart)),
      data: (context, data) => _buildContent(context, ref, data),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Map<String, dynamic> reportData) {
    final selectedWeekStart = ref.watch(weeklyReportDateProvider);
    final today = DateTime.now();

    final weeklyStats = reportData['dailyStats'] as List<dynamic>? ?? [];
    final emotionBreakdown = reportData['emotionBreakdown'] as Map<String, dynamic>? ?? {};

    // 주간 감정 통계 계산
    final emotionCounts = <String, int>{};
    for (final entry in emotionBreakdown.entries) {
      emotionCounts[entry.key] = (entry.value as num?)?.toInt() ?? 0;
    }

    final eventsForStats = emotionCounts.entries
        .expand((e) => List.generate(e.value, (_) => {'emotion': e.key}))
        .toList();

    // 주간 건강 알림 횟수 계산 (슬개골 탐지 횟수)
    final weeklyHealthAlertCount = weeklyStats.length;

    return Column(
      children: [
          DateSelector(
            selectedWeekStart: selectedWeekStart,
            today: today,
            onPrevious: () {
              ref.read(weeklyReportDateProvider.notifier).previousWeek();
            },
            onNext: () {
              ref.read(weeklyReportDateProvider.notifier).nextWeek();
            },
          ),
          AppConstants.h20,
          EmotionStatsSection(title: '주간 감정 통계', events: eventsForStats),
          AppConstants.h20,
          EmotionPieChart(emotionCounts: emotionCounts),
          AppConstants.h20,
          EmotionRatioBar(emotionCounts: emotionCounts),
          AppConstants.h20,
          WeeklyHealthAlertSummary(
            weeklyHealthAlertCount: weeklyHealthAlertCount,
          ),
          AppConstants.h20,
          AiReportSection(
            reportData: reportData,
            emotionCounts: emotionCounts,
            healthAlertCount: weeklyHealthAlertCount,
            statusLabel: '주의',
            statusColor: AppColors.activityStatusColor,
          ),
          const SizedBox(height: 30),
          const Text('주간 활동 패턴', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          WeeklyActivityLineChart(weeklyStats: weeklyStats),
          const SizedBox(height: 30),
        ],
    );
  }

}
