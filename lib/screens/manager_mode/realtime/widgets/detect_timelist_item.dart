import 'package:flutter/material.dart';

class DetectTimelistItem extends StatelessWidget {
final IconData icon;
final Color iconColor;
final String text;
final String time;
final String? highlightText;
final VoidCallback onTap;

const DetectTimelistItem({
   super.key,
   required this.icon,
   required this.iconColor,
   required this.text,
   required this.time,
   this.highlightText,
   required this.onTap,
});

@override
Widget build(BuildContext context) {
   return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
         children: [
            Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
               color: iconColor.withValues(alpha: 0.1),
               shape: BoxShape.circle,
               border: Border.all(
                  color: iconColor.withValues(alpha: 0.3),
                  width: 1,
               ),
            ),
            child: Icon(
               icon,
               color: iconColor,
               size: 20,
            ),
            ),
            const SizedBox(width: 12),
            Expanded(
            child: highlightText != null
                  ? RichText(
                     text: TextSpan(
                        text: text.replaceAll("'$highlightText'", ''),
                        style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        ),
                        children: [
                        TextSpan(
                           text: "'$highlightText'",
                           style: TextStyle(
                              color: Colors.blue[400],
                              fontWeight: FontWeight.bold,
                           ),
                        ),
                        TextSpan(
                           text: " [$time]",
                           style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                           ),
                        ),
                        ],
                     ),
                  )
                  : Text(
                     '$text [$time]',
                     style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                     ),
                  ),
            ),
         ],
      ),
      ),
   );
}
}