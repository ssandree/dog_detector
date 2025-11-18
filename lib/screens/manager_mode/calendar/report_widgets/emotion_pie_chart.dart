import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/index_export.dart';

class EmotionPieChart extends StatelessWidget {
  final Map<String, int> emotionCounts;

  const EmotionPieChart({
    super.key,
    required this.emotionCounts,
  });

  @override
  Widget build(BuildContext context) {
    // 감정 통계 정렬
    final sortedEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // 파이 차트 데이터 계산
    final totalCount = emotionCounts.values.fold(0, (sum, count) => sum + count);
    final pieChartSections = <PieChartSectionData>[];
    
    if (totalCount > 0) {
      final emotionColors = {
        '행복': AppColors.green5,
        '편안': AppColors.green3,
        '불안': AppColors.coral4,
        '화남': AppColors.coral3,
        '공포': AppColors.coral5,
        '공격성': AppColors.errorRed,
      };
      final defaultColor = AppColors.grey4;
      
      for (var entry in sortedEmotions.take(6)) {
        final percentage = (entry.value / totalCount * 100).round();
        final color = emotionColors[entry.key] ?? defaultColor;
        pieChartSections.add(
          PieChartSectionData(
            color: color,
            value: percentage.toDouble(),
            title: '$percentage%',
            radius: 50,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color == AppColors.grey4 ? Colors.black : Colors.white,
            ),
          ),
        );
      }
    }
    
    // 범례 아이템 생성
    final legendItems = sortedEmotions.take(6).map((entry) {
      final emotionColors = {
        '행복': AppColors.green5,
        '편안': AppColors.green3,
        '불안': AppColors.coral4,
        '화남': AppColors.coral3,
        '공포': AppColors.coral5,
        '공격성': AppColors.errorRed,
      };
      return _LegendItem(
        color: emotionColors[entry.key] ?? AppColors.grey4,
        label: entry.key,
      );
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 200,
            child: pieChartSections.isNotEmpty
              ? PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: pieChartSections,
                  ),
                )
              : const Center(child: Text('데이터가 없습니다')),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: legendItems,
          ),
        ),
      ],
    );
  }
}

/// 차트 범례 아이템 위젯
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
