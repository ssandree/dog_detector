import '../../../../core/index_export.dart';

/// 최근 감지된 감정 태그 카드
class EmotionTagsCard extends ConsumerWidget {
  const EmotionTagsCard({super.key});

  Color _getEmotionColor(String emotion) {
    switch (emotion) {
      case '행복':
        return AppColors.green6;
      case '평온':
        return AppColors.green5;
      case '활발':
        return AppColors.green7;
      case '불안':
        return AppColors.activityStatusColor;
      case '화남':
        return AppColors.error;
      default:
        return AppColors.grey6;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emotionTagsAsync = ref.watch(recentEmotionTagsProvider);

    return emotionTagsAsync.when(
      data: (tags) {
        if (tags.isEmpty) {
          return const SizedBox.shrink();
        }

        return AppCards.basic(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '최근 감지된 감정',
                style: TextStyle(
                  fontSize: AppConstants.titleFontSize - 6,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey12,
                ),
              ),
              AppConstants.h12,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.take(3).map((tag) {
                  final emotion = tag['emotion'] as String? ?? '';
                  final color = _getEmotionColor(emotion);
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          emotion,
                          style: TextStyle(
                            fontSize: AppConstants.smallFontSize + 2,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
      loading: () => AppCards.basic(
        padding: const EdgeInsets.all(20),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

