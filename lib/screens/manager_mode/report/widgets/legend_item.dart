import 'package:flutter/material.dart';

/// 차트 범례 아이템 위젯
class LegendItem extends StatelessWidget {
   final Color color;
   final String label;

   const LegendItem({
      super.key,
      required this.color,
      required this.label,
   });

   @override
   Widget build(BuildContext context) {
      return Padding(
         padding: const EdgeInsets.symmetric(vertical: 4.0),
         child: Row(
         children: [
            Container(
               width: 16,
               height: 16,
               color: color,
            ),
            const SizedBox(width: 8),
            Text(
               label,
               style: const TextStyle(fontSize: 14),
            ),
         ],
         ),
      );
   }
}
