import 'package:flutter/material.dart';
import 'detect_timelist_item.dart';
import '../video_evidence_screen.dart';

class DetectTimelist extends StatelessWidget {
   const DetectTimelist({super.key});

   @override
   Widget build(BuildContext context) {
      return ListView(
         shrinkWrap: true,
         physics: const NeverScrollableScrollPhysics(),
         padding: const EdgeInsets.symmetric(horizontal: 16),
         children: [
         DetectTimelistItem(
            icon: Icons.pets,
            iconColor: Colors.orange,
            text: "'편안함' 감정이 높게 나타납니다.",
            highlightText: '편안함',
            time: '14:08',
            onTap: () => _openEvidence(context, '편안함', '오후 2:08에 발생'),
         ),
         DetectTimelistItem(
            icon: Icons.person,
            iconColor: Colors.grey[700]!,
            text: "우리 개 지금 전반적인 상태가 어때?",
            time: '14:08',
            onTap: () => _openEvidence(context, '질문', '오후 2:08에 발생'),
         ),
         DetectTimelistItem(
            icon: Icons.pets,
            iconColor: Colors.orange,
            text: "'편안함' 감정이 감지되었습니다.",
            highlightText: '편안함',
            time: '11:37',
            onTap: () => _openEvidence(context, '편안함', '오전 11:37에 발생'),
         ),
         DetectTimelistItem(
            icon: Icons.notification_important,
            iconColor: Colors.orange,
            text: "음성 메시지를 전달했습니다.",
            time: '11:36',
            onTap: () => _openEvidence(context, '메시지', '오전 11:36에 발생'),
         ),
         DetectTimelistItem(
            icon: Icons.pets,
            iconColor: Colors.orange,
            text: "'불안함' 감정이 감지되었습니다.",
            highlightText: '불안함',
            time: '09:22',
            onTap: () => _openEvidence(context, '불안함', '오전 9:22에 발생'),
         ),
         ],
      );
   }

   void _openEvidence(BuildContext context, String emotionName, String timeText) {
      Navigator.of(context).push(
         PageRouteBuilder(
         opaque: false,
         barrierColor: Colors.black54,
         pageBuilder: (_, __, ___) => VideoEvidenceScreen(
            emotionName: emotionName,
            timeText: timeText,
         ),
         transitionsBuilder: (_, animation, __, child) {
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            return FadeTransition(
               opacity: curved,
               child: ScaleTransition(scale: Tween<double>(begin: 0.98, end: 1).animate(curved), child: child),
            );
         },
         ),
      );
   }
}