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
    // 시간대별로 데이터 그룹화 (오전: 0-11, 오후: 12-17, 저녁: 18-23)
    final morningActivity = <int>[];
    final afternoonActivity = <int>[];
    final eveningActivity = <int>[];

    for (final item in chartData) {
      final hour = int.tryParse(item['hour'] as String? ?? '0') ?? 0;
      final activity = item['activity'] as int? ?? 0;
      
      if (hour < 12) {
        morningActivity.add(activity);
      } else if (hour < 18) {
        afternoonActivity.add(activity);
      } else {
        eveningActivity.add(activity);
      }
    }

    // 각 시간대별 활동량 합산
    final morningTotal = morningActivity.fold<int>(0, (sum, activity) => sum + activity);
    final afternoonTotal = afternoonActivity.fold<int>(0, (sum, activity) => sum + activity);
    final eveningTotal = eveningActivity.fold<int>(0, (sum, activity) => sum + activity);

    // 최대값 계산 (Y축 범위 설정용)
    final maxActivity = [morningTotal, afternoonTotal, eveningTotal].reduce((a, b) => a > b ? a : b);
    final maxY = maxActivity > 0 ? (maxActivity * 1.2).ceil().toDouble() : 20.0;

    // 시간대별 데이터 (x: 0=오전, 1=오후, 2=저녁)
    final timeSlotGroups = [
      {'x': 0, 'activity': morningTotal, 'color': AppColors.green5, 'label': '오전'},
      {'x': 1, 'activity': afternoonTotal, 'color': AppColors.coral4, 'label': '오후'},
      {'x': 2, 'activity': eveningTotal, 'color': AppColors.green3, 'label': '저녁'},
    ];

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
              maxY: maxY,
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
                    reservedSize: 40,
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
                    interval: maxY > 0 ? (maxY / 5).ceil().toDouble() : 5,
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
              barGroups: timeSlotGroups.map((group) {
                return BarChartGroupData(
                  x: group['x'] as int,
                  barRods: [
                    BarChartRodData(
                      toY: (group['activity'] as int).toDouble(),
                      color: group['color'] as Color,
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

