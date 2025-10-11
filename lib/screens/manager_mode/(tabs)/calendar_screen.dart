import 'package:flutter/material.dart';
import '../report/widgets/emotion_ratio_bar.dart';
import '../../../core/index_export.dart';
import '../calendar/widgets/calendar_section.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TopNav.withNotification(
        title: '캘린더',
        onNotificationPressed: () {
          // 알림 기능
        },
      ),
      body: Column(
        children: [
          // 캘린더
          const CalendarSection(),
          
          // 감정 바
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: EmotionRatioBar(
              negativePercent: 60,
              positivePercent: 40,
              negativeLabel: '부정 60%',
              positiveLabel: '긍정 40%',
            ),
          ),
        ],
      ),
    );
  }
}
