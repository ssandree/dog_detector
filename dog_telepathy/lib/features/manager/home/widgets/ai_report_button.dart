import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/app_constants.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/provider/ai_report_provider.dart';
import '../../../../core/provider/current_pet_provider.dart';
import '../../../../core/provider/event_provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_cards.dart';

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
        final statusText = hasEvents
            ? '오늘의 감정 리포트 생성 준비됨'
            : '아직 분석할 데이터가 없어요';
        return AppCards.basic(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: hasEvents ? AppColors.black : AppColors.grey8,
                ),
              ),
              AppConstants.h12,
              AppButton.primary(
                text: hasEvents ? 'AI 리포트 보기' : '데이터가 부족해요',
                onPressed: hasEvents
                    ? () => _showAiReport(context, ref, petId)
                    : () {},
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

  String _formatCreatedAt(DateTime? createdAt) {
    if (createdAt == null) return '';
    return '${createdAt.month}/${createdAt.day} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showAiReport(
    BuildContext context,
    WidgetRef ref,
    int petId,
  ) async {
    final request = DailyReportRequest(
      petId: petId,
      date: DateTime.now(),
    );

    final report = await ref.read(dailyAiReportProvider(request).future);

    showDialog(
      context: context,
      builder: (ctx) {
        final hasSummary = report.summary.trim().isNotEmpty;
        final createdAtText = report.createdAt != null
            ? '생성 시간: ${_formatCreatedAt(report.createdAt)}'
            : '';
        
        return AlertDialog(
          title: const Text('건강 리포트'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (createdAtText.isNotEmpty) ...[
                Text(
                  createdAtText,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey8,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                hasSummary
                    ? report.summary
                    : '아직 생성된 리포트가 없습니다.\n조금만 더 기다려주세요!',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }
}

