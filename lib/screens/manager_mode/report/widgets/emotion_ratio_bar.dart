import 'package:flutter/material.dart';

/// 감정 비율을 표시하는 바 위젯 (부정/긍정)
class EmotionRatioBar extends StatelessWidget {
   final int negativePercent;
   final int positivePercent;
   final String negativeLabel;
   final String positiveLabel;
   final Color negativeColor;
   final Color positiveColor;

   const EmotionRatioBar({
      super.key,
      required this.negativePercent,
      required this.positivePercent,
      this.negativeLabel = '',
      this.positiveLabel = '',
      this.negativeColor = const Color(0xFFE0B29F),
      this.positiveColor = const Color(0xFFA5D6A7),
   });

   @override
   Widget build(BuildContext context) {
      return Row(
         children: [
         Expanded(
            flex: negativePercent,
            child: Container(
               height: 20,
               decoration: BoxDecoration(
               color: negativeColor,
               borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
               ),
               ),
               alignment: Alignment.centerLeft,
               padding: const EdgeInsets.only(left: 10),
               child: Text(
               negativeLabel,
               style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
               ),
               ),
            ),
         ),
         Expanded(
            flex: positivePercent,
            child: Container(
               height: 20,
               decoration: BoxDecoration(
               color: positiveColor,
               borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
               ),
               ),
               alignment: Alignment.centerRight,
               padding: const EdgeInsets.only(right: 10),
               child: Text(
               positiveLabel,
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
