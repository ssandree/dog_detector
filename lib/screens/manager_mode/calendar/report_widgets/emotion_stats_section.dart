import 'package:flutter/material.dart';
import 'rank_chip.dart';
import '../../../../core/index_export.dart';

class EmotionStatsSection extends StatelessWidget {
  final String title;
  final List<dynamic> events;

  const EmotionStatsSection({
    super.key,
    required this.title,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    // 감정 통계 계산
    final emotionCounts = <String, int>{};
    for (var event in events) {
      final emotion = event['emotion'] as String? ?? '';
      if (emotion.isNotEmpty) {
        emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
      }
    }
    
    final sortedEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topEmotions = sortedEmotions.take(3).toList();
    
    final rankChips = [
      if (topEmotions.isNotEmpty)
        RankChip(
          rankLabel: 'Top 1',
          text: '${topEmotions[0].key} ${topEmotions[0].value}회',
          backgroundColor: const Color(0xFFE8F5E9),
          borderColor: const Color(0xFFC8E6C9),
        ),
      if (topEmotions.length > 1)
        RankChip(
          rankLabel: 'Top 2',
          text: '${topEmotions[1].key} ${topEmotions[1].value}회',
          backgroundColor: const Color(0xFFFFF3E0),
          borderColor: const Color(0xFFFFECB3),
        ),
      if (topEmotions.length > 2)
        RankChip(
          rankLabel: 'Top 3',
          text: '${topEmotions[2].key} ${topEmotions[2].value}회',
          backgroundColor: const Color(0xFFE8F5E9),
          borderColor: const Color(0xFFC8E6C9),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: AppConstants.titleFontSize - 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.defaultSpacing - 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: rankChips.length >= 3 
            ? rankChips
            : [
                ...rankChips,
                ...List.generate(3 - rankChips.length, (index) => const SizedBox()),
              ],
        ),
      ],
    );
  }
}
