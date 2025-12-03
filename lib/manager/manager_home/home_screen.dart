// lib/manager/manager_home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/config/app_constants.dart';
import 'widgets/pet_greeting.dart';
import 'widgets/emotion_gauge_card.dart';
import 'widgets/event_count.dart';
import 'widgets/ai_report_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.defaultSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PetGreeting(),
          SizedBox(height: AppConstants.defaultSpacing),
          const EmotionGaugeCard(),
          SizedBox(height: AppConstants.defaultSpacing),
          const EventCountCard(),
          SizedBox(height: AppConstants.defaultSpacing),
          const AiReportButton(),
        ],
      ),
    );
  }
}
