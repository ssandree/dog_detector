import '../../../core/index_export.dart';
import 'widgets/report_widgets.dart';

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
    
    final start = DateTime.tryParse(reportData['startDate'] ?? '') ?? selectedWeekStart;
    final end = DateTime.tryParse(reportData['endDate'] ?? '') ?? selectedWeekStart.add(const Duration(days: 6));
    final dateRangeStr =
        '${start.year.toString().substring(2)}.${start.month.toString().padLeft(2, '0')}.${start.day.toString().padLeft(2, '0')} - '
        '${end.year.toString().substring(2)}.${end.month.toString().padLeft(2, '0')}.${end.day.toString().padLeft(2, '0')}';

    // 제목 동적 설정 (이번 주, 지난 주 등)
    final today = DateTime.now();
    final todayWeekStart = _getWeekStart(today);
    final selectedWeekStartOnly = DateTime(selectedWeekStart.year, selectedWeekStart.month, selectedWeekStart.day);
    final todayWeekStartOnly = DateTime(todayWeekStart.year, todayWeekStart.month, todayWeekStart.day);
    final weeksDiff = todayWeekStartOnly.difference(selectedWeekStartOnly).inDays ~/ 7;
    
    String title;
    if (weeksDiff == 0) {
      title = '이번 주';
    } else if (weeksDiff == 1) {
      title = '지난 주';
    } else {
      title = dateRangeStr;
    }

    final dailyStats = reportData['dailyStats'] as List<dynamic>? ?? [];
    final emotionBreakdown = reportData['emotionBreakdown'] as Map<String, dynamic>? ?? {};

    // 감정 통계 계산
    final emotionCounts = <String, int>{};
    for (final entry in emotionBreakdown.entries) {
      emotionCounts[entry.key] = (entry.value as num?)?.toInt() ?? 0;
    }

    final eventsForStats = emotionCounts.entries
        .expand((e) => List.generate(e.value, (_) => {'emotion': e.key}))
        .toList();

    final healthAlertCount = dailyStats.length;

    return Column(
      children: [
          DateSelector(
            title: title,
            subtitle: dateRangeStr,
            onPrevious: () {
              final success = ref.read(weeklyReportDateProvider.notifier).previousWeek();
              if (!success) {
                // 5일 이전 제한에 도달했을 때 에러 위젯 표시
                _showLimitError(context);
              }
            },
            onNext: () {
              final success = ref.read(weeklyReportDateProvider.notifier).nextWeek();
              if (!success) {
                _showLimitError(context);
              }
            },
          ),
          AppConstants.h20,
          EmotionStatsSection(title: '주간 감정 통계', events: eventsForStats),
          AppConstants.h20,
          EmotionPieChart(emotionCounts: emotionCounts),
          AppConstants.h20,
          EmotionRatioBar(emotionCounts: emotionCounts),
          AppConstants.h20,
          HealthAlertCard(
            events: dailyStats,
            healthAlertCount: healthAlertCount,
            countLabel: '주간 감지 횟수',
          ),
          AppConstants.h20,
          AiReportSection(
            reportData: reportData,
            emotionCounts: emotionCounts,
            healthAlertCount: healthAlertCount,
            statusLabel: '주의',
            statusColor: AppColors.activityStatusColor,
          ),
          const SizedBox(height: 30),
          const Text('주간 활동 패턴', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          WeeklyActivityLineChart(dailyStats: dailyStats),
          const SizedBox(height: 30),
        ],
    );
  }

  /// 주의 시작일(월요일) 계산
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1(월) ~ 7(일)
    return date.subtract(Duration(days: weekday - 1));
  }

  /// 5일 이전 제한에 도달했을 때 에러 위젯 표시
  void _showLimitError(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: AppErrorWidget(
            message: '최대 5일 이전까지만 조회할 수 있습니다.',
            onRetry: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}
