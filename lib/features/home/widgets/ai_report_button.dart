// lib/features/home/widgets/ai_report_button.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_cards.dart';
import '../../pet/application/current_pet_provider.dart';
import '../../event/application/event_provider.dart';

class AiReportButton extends ConsumerWidget {
  const AiReportButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(currentPetProvider);
    final petId = pet?.petId;

    if (petId == null) {
      return const SizedBox.shrink();
    }

    final request = DailyEventRequest(
      petId: petId,
      date: DateTime.now(),
    );

    final eventsAsync = ref.watch(dailyEventsProvider(request));

    return eventsAsync.when(
      data: (dailyEvents) {
        final hasEvents = dailyEvents.events.isNotEmpty;

        return AppCards.basic(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '오늘의 리포트 보기',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              AppConstants.h12,
              hasEvents
                  ? AppButton.primary(
                      text: 'AI 리포트 보기',
                      onPressed: () => context.push(AppRoutes.todayReport),
                      height: 48,
                    )
                  : AppButton.disabled(
                      text: '데이터가 부족해요',
                      height: 48,
                    ),
            ],
          ),
        );
      },

      loading: () => AppCards.basic(
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            AppConstants.w12,
            const Expanded(
              child: Text(
                'AI 리포트 준비 상태를 확인 중이에요...',
                style: TextStyle(color: AppColors.grey8),
              ),
            ),
          ],
        ),
      ),

      error: (error, _) => AppCards.basic(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '리포트 상태를 확인하지 못했어요',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppConstants.h8,
            Text(
              error.toString(),
              style: const TextStyle(color: AppColors.grey8),
            ),
          ],
        ),
      ),
    );
  }
}
