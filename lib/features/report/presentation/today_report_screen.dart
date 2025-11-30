// lib/features/report/presentation/today_report_screen.dart

import 'package:flutter/material.dart';

class TodayReportScreen extends StatelessWidget {
  const TodayReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("오늘의 AI 리포트 (임시)"),
      ),
      body: const Center(
        child: Text(
          "여기에 AI 리포트가 표시될 예정입니다.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
