import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/app_constants.dart';
import '../../../../core/widgets/base_scaffold.dart';
import 'widgets/pet_greeting.dart';
import 'widgets/emotion_gauge_card.dart';

class ManagerHomeScreen extends ConsumerWidget {
  const ManagerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: HorizontalPadding(
        horizontalPadding: AppConstants.defaultSpacing,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            SizedBox(height: AppConstants.defaultSpacing),
            PetGreeting(),
            SizedBox(height: AppConstants.defaultSpacing),
            EmotionGaugeCard(),
            SizedBox(height: AppConstants.defaultSpacing),
          ],
        ),
      ),
    );
  }
}