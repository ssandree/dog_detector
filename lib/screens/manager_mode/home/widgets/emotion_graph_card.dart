import '../../../../core/index_export.dart';

class EmotionGraphCard extends ConsumerWidget {
  const EmotionGraphCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emotionDataAsync = ref.watch(emotionDataProvider);

    return AppCards.basic(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '최근 24시간 감정 분석',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grey12,
            ),
          ),
          const SizedBox(height: 16),
          emotionDataAsync.when(
            data: (emotionData) => Column(
              children: emotionData.map((data) => EmotionBarItem(
                emotion: data['emotion'] as String,
                percentage: data['percentage'] as int,
                color: Color(int.parse((data['color'] as String).replaceFirst('#', '0xFF'))),
              )).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(
                '데이터를 불러오는데 실패했습니다: $error',
                style: const TextStyle(color: AppColors.grey8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmotionBarItem extends StatelessWidget {
  final String emotion;
  final int percentage;
  final Color color;

  const EmotionBarItem({
    super.key,
    required this.emotion,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              emotion,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.grey2,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  height: 8,
                  width: MediaQuery.of(context).size.width * (percentage / 100) * 0.4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$percentage%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.grey8,
            ),
          ),
        ],
      ),
    );
  }
}
