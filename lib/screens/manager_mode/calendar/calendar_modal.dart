import '../../../core/index_export.dart';
import 'daily_report.dart';

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
               child: DailyReport(selectedDate: selectedDate),
               ),
            ),
         ],
         ),
      );
   }
}
