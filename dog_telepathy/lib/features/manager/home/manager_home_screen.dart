// lib/features/manager/manager_home_screen.dart
import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/app_constants.dart';
import 'widgets/pet_greeting_card.dart';
import 'widgets/emotion_gauge_card.dart';

/// 매니저 홈 화면
class ManagerHomeScreen extends StatelessWidget {
  const ManagerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.beige1, // 베이지색 배경
            AppColors.beige2,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            PetGreetingCard(),
            AppConstants.h16,
            EmotionGaugeCard(),
            AppConstants.h32,
          ],
        ),
      ),
    );
  }
}
