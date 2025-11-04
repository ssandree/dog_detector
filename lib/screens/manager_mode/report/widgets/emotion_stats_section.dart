import 'package:flutter/material.dart';
import 'rank_chip.dart';
import '../../../../core/index_export.dart';
import '../../../../models/calendar_data.dart';

class EmotionStatsSection extends StatelessWidget {
  final String title;
  final List<RankChipData> rankChips;

  const EmotionStatsSection({
    super.key,
    required this.title,
    required this.rankChips,
  });

  @override
  Widget build(BuildContext context) {
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
          children: rankChips.map((chip) => RankChip(
            rankLabel: chip.rankLabel,
            text: chip.text,
            backgroundColor: chip.backgroundColor,
            borderColor: chip.borderColor,
          )).toList(),
        ),
      ],
    );
  }
}
