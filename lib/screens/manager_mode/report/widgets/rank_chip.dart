import 'package:flutter/material.dart';

/// 순위 칩 위젯 (Top 1, Top 2 등)
class RankChip extends StatelessWidget {
final String rankLabel;
final String text;
final Color backgroundColor;
final Color borderColor;

const RankChip({
   super.key,
   required this.rankLabel,
   required this.text,
   required this.backgroundColor,
   required this.borderColor,
});

@override
Widget build(BuildContext context) {
   return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
         color: borderColor,
         width: 1,
      ),
      ),
      child: Column(
      children: [
         Text(
            rankLabel,
            style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            ),
         ),
         Text(
            text,
            style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            ),
         ),
      ],
      ),
   );
   }
}
