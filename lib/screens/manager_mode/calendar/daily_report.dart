import '../../../core/index_export.dart';
import '../../../widgets/app_error_banner.dart';
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
          // 날짜 제목 표시
          Center(
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppConstants.titleFontSize - 6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: AppConstants.smallFontSize,
                    color: AppColors.grey6,
                  ),
                ),
              ],
            ),
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
}
