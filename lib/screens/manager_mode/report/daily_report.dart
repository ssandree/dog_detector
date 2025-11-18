import '../../../core/index_export.dart';
import 'widgets/report_widgets.dart';

class DailyReport extends ConsumerWidget {
  const DailyReport({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(dailyReportDateProvider);
    final dailyReportAsync = ref.watch(dailyReportProvider(selectedDate));

    return AsyncValueWidget<Map<String, dynamic>>(
      asyncValue: dailyReportAsync,
      onRetry: () => ref.invalidate(dailyReportProvider(selectedDate)),
      data: (context, data) => _buildContent(context, ref, data),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Map<String, dynamic> reportData) {
    final selectedDate = ref.watch(dailyReportDateProvider);
    
    // 날짜 처리 - reportData에 날짜가 있으면 사용하고, 없으면 selectedDate 사용
    final dateString = reportData['date'] as String?;
    final dateTime = dateString != null 
        ? (DateTime.tryParse(dateString) ?? selectedDate)
        : selectedDate;
    final dateStr =
        '${dateTime.year.toString().substring(2)}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';

    // 제목 동적 설정 (오늘, 어제, 그저께 등)
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final selectedDateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final daysDiff = todayDate.difference(selectedDateOnly).inDays;
    
    String title;
    if (daysDiff == 0) {
      title = '오늘';
    } else if (daysDiff == 1) {
      title = '어제';
    } else if (daysDiff == 2) {
      title = '그저께';
    } else {
      title = dateStr;
    }

    // 데이터 추출
    final events = reportData['events'] as List<dynamic>? ?? [];
    final chartData = reportData['chartData'] as List<dynamic>? ?? [];

    // 감정 통계
    final emotionCounts = <String, int>{};
    for (var e in events) {
      final emotion = e['emotion'] as String?;
      if (emotion != null && emotion.isNotEmpty) {
      emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
      }
    }

    final healthAlertCount = events.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          DateSelector(
            title: title,
            subtitle: dateStr,
            onPrevious: () {
              final success = ref.read(dailyReportDateProvider.notifier).previousDay();
              if (!success) {
                _showLimitError(context);
              }
            },
            onNext: () {
              final success = ref.read(dailyReportDateProvider.notifier).nextDay();
              if (!success) {
                _showLimitError(context);
              }
            },
          ),
          AppConstants.h20,
          EmotionStatsSection(title: '감정 통계', events: events),
          AppConstants.h20,
          EmotionPieChart(emotionCounts: emotionCounts),
          AppConstants.h20,
          EmotionRatioBar(emotionCounts: emotionCounts),
          AppConstants.h20,
          TimeSlotBarChart(chartData: chartData),
          AppConstants.h20,
          HealthAlertCard(events: events, healthAlertCount: healthAlertCount),
          AppConstants.h20,
          AiReportSection(
            reportData: reportData,
            emotionCounts: emotionCounts,
            healthAlertCount: healthAlertCount,
          ),
          const SizedBox(height: 30),
        ],
    );
  }

  /// 날짜 제한에 도달했을 때 에러 위젯 표시
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
