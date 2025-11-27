import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/app_constants.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/models/event_info.dart';

class HourlyChart extends StatelessWidget {
  final HourlyBuckets buckets;

  const HourlyChart({super.key, required this.buckets});

  @override
  Widget build(BuildContext context) {
    final groups = buckets.toBarGroups();
    final maxY = math.max(buckets.maxCount.toDouble(), 1.0);

    return Container(
      height: 210,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.beige2.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '시간대별 이벤트',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.grey12,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxY + 1,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, _, rod, __) {
                      return BarTooltipItem(
                        '${group.x.toString().padLeft(2, '0')}시\n${rod.toY.round()}건',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: math.max((maxY / 3).ceilToDouble(), 1),
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.grey7,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, _) {
                        final hour = value.toInt();
                        if (hour % 4 != 0) return const SizedBox.shrink();
                        return Text(
                          '${hour.toString().padLeft(2, '0')}h',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.grey7,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(show: true, horizontalInterval: 1),
                borderData: FlBorderData(show: false),
                barGroups: groups,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HourlyBuckets {
  final List<int> counts;

  HourlyBuckets(this.counts);

  factory HourlyBuckets.fromEvents(List<EventInfo> events) {
    final counts = List<int>.filled(24, 0);
    for (final event in events) {
      counts[event.startTime.hour]++;
    }
    return HourlyBuckets(counts);
  }

  int get maxCount => counts.fold(0, math.max);

  List<BarChartGroupData> toBarGroups() {
    return counts.asMap().entries.map((entry) {
      final hour = entry.key;
      final count = entry.value.toDouble();
      return BarChartGroupData(
        x: hour,
        barRods: [
          BarChartRodData(
            toY: count,
            width: 10,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.green4,
                AppColors.green6,
              ],
            ),
          ),
        ],
      );
    }).toList();
  }
}

