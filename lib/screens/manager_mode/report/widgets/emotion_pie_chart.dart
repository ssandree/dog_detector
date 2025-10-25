import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'legend_item.dart';
import '../../../../core/index_export.dart';

class EmotionPieChart extends StatelessWidget {
  final List<PieChartSectionData> sections;
  final List<LegendItemData> legendItems;

  const EmotionPieChart({
    super.key,
    required this.sections,
    required this.legendItems,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                sections: sections,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.defaultSpacing + 4),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: legendItems.map((item) => LegendItem(
              color: item.color,
              label: item.label,
            )).toList(),
          ),
        ),
      ],
    );
  }
}

class LegendItemData {
  final Color color;
  final String label;

  LegendItemData({
    required this.color,
    required this.label,
  });
}
