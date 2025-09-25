import 'package:flutter/material.dart';

class DailyReport extends StatelessWidget {
  const DailyReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "오늘의 리포트 화면",
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
