import 'package:flutter/material.dart';

class StateSummary extends StatelessWidget {
  final String emotion;
  final String emoji;

  const StateSummary({
    super.key,
    required this.emotion,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              text: "현재 반려견은 '",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: emotion,
                  style: TextStyle(
                    color: Colors.blue[400],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text: "' 상태입니다.",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
