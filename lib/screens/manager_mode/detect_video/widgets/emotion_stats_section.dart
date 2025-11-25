import '../../../../core/index_export.dart';
import 'emotion_utils.dart';

/// 감정 통계 섹션 위젯
class EmotionStatsSection extends StatelessWidget {
  final Map<String, int> emotionCounts;

  const EmotionStatsSection({
    super.key,
    required this.emotionCounts,
  });

  @override
  Widget build(BuildContext context) {
    return AppCards.basic(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '탐지된 감정',
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
            children: emotionCounts.entries.map((entry) {
              final emotion = entry.key;
              final count = entry.value;
              final color = EmotionUtils.getEmotionColor(emotion);

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
                      '$emotion ($count)',
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
  }
}

