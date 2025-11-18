import 'package:flutter/material.dart';
import '../../../../core/index_export.dart';

/// 감정 비율을 표시하는 바 위젯 (부정/긍정)
class EmotionRatioBar extends StatelessWidget {
   final Map<String, int> emotionCounts;
   final Color? negativeColor;
   final Color? positiveColor;

   const EmotionRatioBar({
      super.key,
      required this.emotionCounts,
      this.negativeColor,
      this.positiveColor,
   });

   @override
   Widget build(BuildContext context) {
      // 감정 비율 계산 (긍정/부정)
      final positiveEmotions = ['행복', '편안'];
      final negativeEmotions = ['불안', '화남', '공포', '공격성'];
      int positiveCount = 0;
      int negativeCount = 0;
      for (var entry in emotionCounts.entries) {
        if (positiveEmotions.contains(entry.key)) {
          positiveCount += entry.value;
        } else if (negativeEmotions.contains(entry.key)) {
          negativeCount += entry.value;
        }
      }
      final totalEmotionCount = positiveCount + negativeCount;
      final negativePercent = totalEmotionCount > 0 ? (negativeCount / totalEmotionCount * 100).round() : 0;
      final positivePercent = totalEmotionCount > 0 ? (positiveCount / totalEmotionCount * 100).round() : 0;
      
      final negativeColorFinal = negativeColor ?? AppColors.coral3;
      final positiveColorFinal = positiveColor ?? AppColors.green3;
      
      return Row(
         children: [
         Expanded(
            flex: negativePercent > 0 ? negativePercent : 1,
            child: Container(
               height: 20,
               decoration: BoxDecoration(
               color: negativeColorFinal,
               borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
               ),
               ),
               alignment: Alignment.centerLeft,
               padding: const EdgeInsets.only(left: 10),
               child: Text(
               '부정 $negativePercent%',
               style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
               ),
               ),
            ),
         ),
         Expanded(
            flex: positivePercent > 0 ? positivePercent : 1,
            child: Container(
               height: 20,
               decoration: BoxDecoration(
               color: positiveColorFinal,
               borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
               ),
               ),
               alignment: Alignment.centerRight,
               padding: const EdgeInsets.only(right: 10),
               child: Text(
               '긍정 $positivePercent%',
               style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
               ),
            ),
          ),
        ),
      ],
    );
  }
}
