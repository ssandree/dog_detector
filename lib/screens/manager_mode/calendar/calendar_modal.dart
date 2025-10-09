import 'package:flutter/material.dart';
import '../../../widgets/buttons/app_buttons.dart';
import '../../../widgets/cards/app_cards.dart';
import '../../../constants/app_constants.dart';
import '../../../theme/app_colors.dart';

class CalendarModal extends StatelessWidget {
   final DateTime currentDate;
   final int day;

   const CalendarModal({
      super.key,
      required this.currentDate,
      required this.day,
   });

   @override
   Widget build(BuildContext context) {
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
               child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     // 날짜 제목
                     Text(
                     '${currentDate.month}월 ${day}일',
                     style: const TextStyle(
                        fontSize: AppConstants.titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                     ),
                     ),
                     const SizedBox(height: AppConstants.defaultSpacing + 4),

                     // 슬개골 탈구 의심 행동 감지 알림
                     AppCards.alert(
                        message: day == 10 ? '슬개골 탈구 의심 행동이 2회 감지되었어요' : '슬개골 탈구 의심 행동이 1회 감지되었어요',
                        icon: Icons.warning_amber_rounded,
                        backgroundColor: AppColors.green1,
                        iconColor: AppColors.green5,
                        textColor: AppColors.green8,
                     ),
                     const SizedBox(height: AppConstants.defaultSpacing + 4),
                     
                     // 감정 진행 바
                     Row(
                     children: [
                        Expanded(
                           flex: 60,
                           child: Container(
                           height: 20,
                           decoration: BoxDecoration(
                              color: AppColors.coral2,
                              borderRadius: const BorderRadius.only(
                                 topLeft: Radius.circular(AppConstants.smallBorderRadius - 2),
                                 bottomLeft: Radius.circular(AppConstants.smallBorderRadius - 2),
                              ),
                           ),
                           alignment: Alignment.centerLeft,
                           padding: const EdgeInsets.only(left: AppConstants.smallSpacing + 2),
                           child: const Text(
                              '부정 감정 60%',
                              style: TextStyle(color: AppColors.black, fontSize: AppConstants.smallFontSize),
                           ),
                           ),
                        ),
                        Expanded(
                           flex: 40,
                           child: Container(
                           height: 20,
                           decoration: BoxDecoration(
                              color: AppColors.green2,
                              borderRadius: const BorderRadius.only(
                                 topRight: Radius.circular(AppConstants.smallBorderRadius - 2),
                                 bottomRight: Radius.circular(AppConstants.smallBorderRadius - 2),
                              ),
                           ),
                           alignment: Alignment.centerRight,
                           padding: const EdgeInsets.only(right: AppConstants.smallSpacing + 2),
                           child: const Text(
                              '긍정 감정 40%',
                              style: TextStyle(color: AppColors.black, fontSize: AppConstants.smallFontSize),
                           ),
                           ),
                        ),
                     ],
                     ),
                     const SizedBox(height: AppConstants.defaultSpacing + 4),

                     // 일일 분석 바로가기 버튼
                     AppButtons.outline(
                        text: '일일 분석 바로가기',
                        onPressed: () {
                           Navigator.pop(context);
                           // 일일 분석 화면으로 이동
                           Navigator.pushNamed(context, '/daily-report');
                        },
                        height: 50,
                     ),
                     const SizedBox(height: AppConstants.defaultSpacing + 4),

                     // 타임라인 보기
                     const Text(
                     '타임라인 보기',
                     style: TextStyle(
                        fontSize: AppConstants.titleFontSize - 6,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                     ),
                     ),
                     const SizedBox(height: AppConstants.defaultSpacing - 1),
                     
                     // 타임라인 항목들
                     _buildTimelineItem('오전 11:00'),
                     _buildTimelineItem('오후 3:30'),
                  ],
               ),
               ),
            ),
         ],
         ),
      );
   }

   Widget _buildTimelineItem(String time) {
      return Padding(
         padding: const EdgeInsets.only(bottom: AppConstants.smallSpacing + 4),
         child: Row(
         children: [
            Container(
               width: 8,
               height: 8,
               decoration: const BoxDecoration(
               color: AppColors.green5,
               shape: BoxShape.circle,
               ),
            ),
            const SizedBox(width: AppConstants.smallSpacing),
            Text(
               time,
               style: const TextStyle(
               fontSize: AppConstants.defaultFontSize - 2,
               fontWeight: FontWeight.bold,
               color: AppColors.black,
               ),
            ),
            const SizedBox(width: AppConstants.smallSpacing),
            Expanded(
               child: Container(
               height: 40,
               decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                  border: Border.all(
                     color: AppColors.grey3,
                     width: 1,
                  ),
               ),
               ),
            ),
         ],
         ),
      );
   }
}
