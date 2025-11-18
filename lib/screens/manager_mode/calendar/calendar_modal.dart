import '../../../core/index_export.dart';
import '../report/widgets/emotion_ratio_bar.dart';

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
                  data: (reportData) {
                     // 감정 통계 계산
                     final events = reportData['events'] as List<dynamic>? ?? [];
                     final emotionCounts = <String, int>{};
                     for (var e in events) {
                        final emotion = e['emotion'] as String?;
                        if (emotion != null && emotion.isNotEmpty) {
                           emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
                        }
                     }
                     
                     final healthAlertCount = events.length;
                     
                     return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           // 날짜 제목
                           Text(
                              '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일',
                              style: const TextStyle(
                                 fontSize: AppConstants.titleFontSize,
                                 fontWeight: FontWeight.bold,
                                 color: AppColors.black,
                              ),
                           ),
                           const SizedBox(height: AppConstants.defaultSpacing + 4),

                           // 슬개골 탈구 의심 행동 감지 알림
                           AppCards.alert(
                              message: healthAlertCount > 1 
                                 ? '슬개골 탈구 의심 행동이 $healthAlertCount회 감지되었어요' 
                                 : healthAlertCount == 1
                                    ? '슬개골 탈구 의심 행동이 1회 감지되었어요'
                                    : '슬개골 탈구 의심 행동이 감지되지 않았어요',
                              icon: Icons.warning_amber_rounded,
                              backgroundColor: AppColors.green1,
                              iconColor: AppColors.green5,
                              textColor: AppColors.green8,
                           ),
                           const SizedBox(height: AppConstants.defaultSpacing + 4),
                           
                           // 감정 비율 바 (EmotionRatioBar 위젯 사용)
                           if (emotionCounts.isNotEmpty)
                              EmotionRatioBar(emotionCounts: emotionCounts)
                           else
                              Container(
                                 height: 20,
                                 decoration: BoxDecoration(
                                    color: AppColors.grey3,
                                    borderRadius: BorderRadius.circular(10),
                                 ),
                                 alignment: Alignment.center,
                                 child: const Text(
                                    '감정 데이터가 없습니다',
                                    style: TextStyle(
                                       color: AppColors.black,
                                       fontSize: AppConstants.smallFontSize,
                                    ),
                                 ),
                              ),
                           const SizedBox(height: AppConstants.defaultSpacing + 4),

                           // 일일 분석 바로가기 버튼
                           AppButtons.outline(
                              text: '일일 분석 바로가기',
                              onPressed: () {
                                 Navigator.pop(context);
                                 // 매니저 홈으로 이동 (사용자가 리포트 탭 선택 필요)
                                context.push(AppRoutes.managerHome);
                              },
                              height: 50,
                           ),
                           const SizedBox(height: AppConstants.defaultSpacing + 4),
                        ],
                     );
                  },
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
}
