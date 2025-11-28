import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_constants.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/models/event_info.dart';
import '../../../../core/provider/event_provider.dart';
import '../../../../core/widgets/app_cards.dart';

class RecentEmotionPanel extends ConsumerWidget {
  final int petId;
  const RecentEmotionPanel({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(
      petEventsProvider(PetEventsRequest(petId: petId, limit: 10)),
    );

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return _buildEmptyCard();
        }

        final latest = events.first;
        final recentItems = events.take(3).toList();

        final currentInfo = _emotionInfo(latest.finalEmotion);
        final delayText = _formatDelay(latest.startTime);

        return AppCards.basic(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '현재 감정 (지연 포함)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.grey12,
                ),
              ),
              AppConstants.h12,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(currentInfo.emoji, style: const TextStyle(fontSize: 42)),
                  AppConstants.w12,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentInfo.label,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey12,
                        ),
                      ),
                      Text(
                        '최근 분석됨 ($delayText)',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.grey7,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              AppConstants.h20,
              const Text(
                '최근 분석된 감정',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey12,
                ),
              ),
              AppConstants.h12,
              ...recentItems.map(_RecentEmotionRow.new),
              AppConstants.h20,
              const Text(
                '※ 감정 분석은 최대 1분 지연될 수 있어요.',
                style: TextStyle(fontSize: 12, color: AppColors.grey7),
              ),
            ],
          ),
        );
      },
      loading: () => AppCards.basic(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _loadingBar(width: 140),
            AppConstants.h12,
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.grey2,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                AppConstants.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _loadingBar(),
                      AppConstants.h8,
                      _loadingBar(width: 120),
                    ],
                  ),
                ),
              ],
            ),
            AppConstants.h20,
            _loadingBar(width: 160),
            AppConstants.h12,
            _loadingBar(),
            AppConstants.h8,
            _loadingBar(),
          ],
        ),
      ),
      error: (error, _) => AppCards.basic(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '감정 정보를 불러올 수 없어요',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.errorRed,
              ),
            ),
            AppConstants.h8,
            Text(
              '$error',
              style: const TextStyle(color: AppColors.grey7, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return AppCards.basic(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '최근 감정 데이터가 없습니다.',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.grey9,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '카메라가 새로운 이벤트를 감지하면 자동으로 감정 요약이 표시됩니다.',
            style: TextStyle(fontSize: 13, color: AppColors.grey7),
          ),
        ],
      ),
    );
  }

  _EmotionDisplay _emotionInfo(String? emotion) {
    switch (emotion) {
      case 'happy':
        return const _EmotionDisplay('😄', '행복');
      case 'calm':
        return const _EmotionDisplay('🙂', '평온');
      case 'anxious':
        return const _EmotionDisplay('😟', '약간 불안');
      case 'sad':
        return const _EmotionDisplay('😢', '슬픔');
      case 'angry':
        return const _EmotionDisplay('😠', '화남');
      case 'neutral':
        return const _EmotionDisplay('😐', '중립');
      default:
        return const _EmotionDisplay('🤔', '분석 중');
    }
  }

  String _formatDelay(DateTime startTime) {
    final diff = DateTime.now().difference(startTime);
    if (diff.inSeconds < 5) {
      return '방금 전';
    }
    if (diff.inMinutes < 1) {
      return '${diff.inSeconds}초 전';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes}분 전';
    }
    return '${diff.inHours}시간 전';
  }

  Widget _loadingBar({double? width}) {
    return Container(
      width: width ?? double.infinity,
      height: 12,
      decoration: BoxDecoration(
        color: AppColors.grey2,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _RecentEmotionRow extends StatelessWidget {
  final EventInfo event;
  const _RecentEmotionRow(this.event);

  @override
  Widget build(BuildContext context) {
    final info = _emotionInfo(event.finalEmotion);
    final timeLabel = DateFormat('HH:mm').format(event.startTime);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '[$timeLabel]',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.grey9,
            ),
          ),
          AppConstants.w8,
          Text(
            '${info.emoji} ${info.label}',
            style: const TextStyle(fontSize: 15, color: AppColors.grey12),
          ),
        ],
      ),
    );
  }

  static _EmotionDisplay _emotionInfo(String? emotion) {
    switch (emotion) {
      case 'happy':
        return const _EmotionDisplay('😊', '행복');
      case 'calm':
        return const _EmotionDisplay('🙂', '평온');
      case 'anxious':
        return const _EmotionDisplay('😟', '약간 불안');
      case 'sad':
        return const _EmotionDisplay('😢', '슬픔');
      case 'angry':
        return const _EmotionDisplay('😠', '화남');
      case 'neutral':
        return const _EmotionDisplay('😐', '중립');
      default:
        return const _EmotionDisplay('🤔', '분석 중');
    }
  }
}

class _EmotionDisplay {
  final String emoji;
  final String label;
  const _EmotionDisplay(this.emoji, this.label);
}
