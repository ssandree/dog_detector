import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/provider/current_pet_provider.dart';

class PetGreetingCard extends ConsumerWidget {
  const PetGreetingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petInfo = ref.watch(currentPetProvider);
    final isPetRegistered = petInfo != null;
    final petName = petInfo?.name ?? '';
    
    Widget cardContent = Row(
      children: [
        // 강아지 얼굴 이모지
        const Text(
          '🐶',
          style: TextStyle(fontSize: 40),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                  isPetRegistered 
                    ? '안녕하세요, $petName님! 💕'
                    : '강아지 정보를 등록해주세요',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey12,
                    height: 1.3,
                  ),
                ),
                if (isPetRegistered) ...[
                  AppConstants.h4,
                  const Text(
                    '오늘도 함께하는 따뜻한 하루가 되길 바라요 ✨',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey9,
                      height: 1.4,
                    ),
                  ),
                ],
            ],
          ),
        ),
      ],
    );
    
    // 강아지 정보가 없으면 클릭 가능하게
    if (!isPetRegistered) {
      return InkWell(
        onTap: () => context.push(AppRoutes.managerPetRegistration),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: cardContent,
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: cardContent,
    );
  }
}
