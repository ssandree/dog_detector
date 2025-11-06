import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/index_export.dart';

class TimeSlotBarChart extends StatelessWidget {
  final List<dynamic> chartData;
  final String title;

  const TimeSlotBarChart({
    super.key,
    required this.chartData,
    this.title = '시간대별 감정 변화',
  });

  @override
  Widget build(BuildContext context) {
    final timeSlotData = chartData.map((item) {
      final hour = item['hour'] as String? ?? '00';
      final activity = item['activity'] as int? ?? 0;
      return {'hour': hour, 'activity': activity};
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.grey1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey3),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 20,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.round()}회',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      const style = TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      );
                      Widget text;
                      switch (value.toInt()) {
                        case 0:
                          text = const Text('오전', style: style);
                          break;
                        case 1:
                          text = const Text('오후', style: style);
                          break;
                        case 2:
                          text = const Text('저녁', style: style);
                          break;
                        default:
                          text = const Text('', style: style);
                          break;
                      }
                      return SideTitleWidget(
                        meta: meta,
                        space: 16,
                        child: text,
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 5,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              barGroups: timeSlotData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final activity = data['activity'] as int? ?? 0;
                final hour = int.tryParse(data['hour'] as String? ?? '0') ?? 0;
                final isMorning = hour < 12;
                final isAfternoon = hour >= 12 && hour < 18;
                final color = isMorning 
                  ? AppColors.green5 
                  : isAfternoon 
                    ? AppColors.coral4 
                    : AppColors.green3;
                
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: activity.toDouble(),
                      color: color,
                      width: 22,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

