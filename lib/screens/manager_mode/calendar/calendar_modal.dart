import '../../../core/index_export.dart';
import '../../../widgets/app_error_banner.dart';
import 'report_widgets/report_widgets.dart';

class CalendarModal extends ConsumerWidget {
   final DateTime currentDate;
   final int day;

   const CalendarModal({
      super.key,
      required this.currentDate,
      required this.day,
   });

   @override
   Widget build(BuildContext context, WidgetRef ref) {
      // 전체 날짜 구성 (년, 월, 일)
      final selectedDate = DateTime(currentDate.year, currentDate.month, day);
      
      // 해당 날짜의 리포트 데이터 가져오기
      final dailyReportAsync = ref.watch(dailyReportProvider(selectedDate));
      
      return Container(
         height: MediaQuery.of(context).size.height * 0.6,
         decoration: const BoxDecoration(
         color: AppColors.white,
         borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppConstants.largeBorderRadius),
            topRight: Radius.circular(AppConstants.largeBorderRadius),
         ),
         ),
      child: Column(
         children: [
            // 모달 핸들
            Container(
               margin: const EdgeInsets.only(top: AppConstants.smallSpacing),
               width: 40,
               height: 4,
               decoration: BoxDecoration(
               color: AppColors.grey4,
               borderRadius: BorderRadius.circular(2),
            ),
            ),
            
            // 모달 내용
            Expanded(
               child: Padding(
               padding: AppConstants.cameraSettingPadding,
               child: dailyReportAsync.when(
                  data: (reportData) => _buildContent(context, ref, reportData, selectedDate),
                  loading: () => const Center(
                     child: Padding(
                        padding: EdgeInsets.all(AppConstants.defaultSpacing),
                        child: CircularProgressIndicator(),
                     ),
                  ),
                  error: (error, stack) => Center(
                     child: Padding(
                        padding: const EdgeInsets.all(AppConstants.defaultSpacing),
                        child: AppErrorWidget(
                           message: '데이터를 불러오는데 실패했습니다',
                           onRetry: () => ref.invalidate(dailyReportProvider(selectedDate)),
                        ),
                     ),
                  ),
               ),
               ),
            ),
         ],
         ),
      );
   }

   Widget _buildContent(BuildContext context, WidgetRef ref, Map<String, dynamic> reportData, DateTime selectedDate) {
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

      return SingleChildScrollView(
         child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // 날짜 제목 (DateSelector 대신 날짜만 표시)
               Column(
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
         ),
      );
   }
}
