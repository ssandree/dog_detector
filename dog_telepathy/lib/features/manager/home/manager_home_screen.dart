import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/app_constants.dart';
import '../../../../core/widgets/base_scaffold.dart';
import 'widgets/pet_greeting.dart';
import 'widgets/emotion_gauge_card.dart';
import 'widgets/event_count.dart';
import 'widgets/ai_report_button.dart';

class ManagerHomeScreen extends ConsumerWidget {
  const ManagerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: HorizontalPadding(
        horizontalPadding: AppConstants.defaultSpacing,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: AppConstants.defaultSpacing),
            const PetGreeting(),
            SizedBox(height: AppConstants.defaultSpacing),
            const EmotionGaugeCard(),
            SizedBox(height: AppConstants.defaultSpacing),
            const EventCountCard(),
            SizedBox(height: AppConstants.defaultSpacing),
            const AiReportButton(),
            SizedBox(height: AppConstants.defaultSpacing),
          ],
        ),
      ),
    );
  }
}