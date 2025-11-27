import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/app_constants.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/provider/calendar_provider.dart';
import '../../../../core/provider/event_provider.dart';
import '../../../../core/service/event/event_service.dart';

class MonthlyEventsChart extends ConsumerWidget {
  const MonthlyEventsChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarProvider);
    final petId = calendarState.petId;
    if (petId == 0) {
      return const _ChartContainer(
        child: Text(
          '반려견 정보를 확인할 수 없어요.\n마이 펫 등록 후 이용해주세요.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.grey8,
          ),
        ),
      );
    }

    final request = MonthlyEventRequest(
      petId: petId,
      year: calendarState.year,
      month: calendarState.month,
    );

    final monthlyAsync = ref.watch(monthlyEventsProvider(request));

    return monthlyAsync.when(
      data: (summary) {
        if (summary.days.isEmpty) {
          return const _ChartContainer(
            child: Text(
              '이번 달 이벤트 데이터가 아직 없어요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey8),
            ),
          );
        }
        return _MonthlyChartContent(summary: summary);
      },
      loading: () => const _ChartContainer(
        child: SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => _ChartContainer(
        child: Text(
          '월간 데이터를 불러오지 못했어요.\n${error.toString()}',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.errorRed),
        ),
      ),
    );
  }
}

class _MonthlyChartContent extends StatelessWidget {
  final MonthlyEventsSummary summary;

  const _MonthlyChartContent({required this.summary});

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(summary.year, summary.month + 1, 0).day;
    final bars = List.generate(daysInMonth, (index) {
      final day = index + 1;
      final stat = summary.days[day];
      final total = stat?.totalEvents.toDouble() ?? 0;
      return BarChartGroupData(
        x: day,
        barRods: [
          BarChartRodData(
            toY: total,
            width: 6,
            borderRadius: BorderRadius.circular(3),
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color(0xFFB0BEC5),
                Color(0xFFE0E0E0),
              ],
            ),
          ),
        ],
      );
    });

    final smoothedLineSpots = List.generate(daysInMonth, (index) {
      final day = index + 1;
      final stat = summary.days[day];
      final positive = (stat?.happy ?? 0) + (stat?.calm ?? 0);
      final negative = (stat?.angry ?? 0) + (stat?.fear ?? 0);
      final total = positive + negative;
      final rawScore = total == 0 ? 50.0 : (positive / total * 100);
      final clampedScore = rawScore.clamp(5.0, 95.0);
      return FlSpot(day.toDouble(), clampedScore);
    });

    final patellaCount = summary.days.values.fold<int>(
      0,
      (sum, stat) => sum + stat.fear,
    );

    final barMaxY = bars.fold<double>(
      0,
      (prev, group) => math.max(prev, group.barRods.first.toY),
    );

    return _ChartContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${summary.year}년 ${summary.month}월 이벤트 요약',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.grey12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '이달의 슬개골 탈구 감지: $patellaCount회',
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.grey8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              _LegendDot(color: Color(0xFF90A4AE), label: '에너지 레벨(감지 횟수)'),
              SizedBox(width: 12),
              _LegendDot(color: AppColors.green5, label: '평균 감정 점수'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                BarChart(
                  BarChartData(
                    maxY: (barMaxY + 2).clamp(4, 40),
                    minY: 0,
                    alignment: BarChartAlignment.spaceBetween,
                    groupsSpace: 2,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 2,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppColors.grey3,
                        strokeWidth: 0.5,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: math.max(1, (barMaxY / 3).ceilToDouble()),
                          getTitlesWidget: (value, _) => Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          getTitlesWidget: (value, _) {
                            const ticks = {1, 6, 11, 16, 21, 26};
                            if (!ticks.contains(value.toInt())) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 11),
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
                    barGroups: bars,
                  ),
                ),
                IgnorePointer(
                  child: LineChart(
                    LineChartData(
                      minX: 1,
                      maxX: daysInMonth.toDouble(),
                      minY: 0,
                      maxY: 100,
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: smoothedLineSpots,
                          isCurved: true,
                          color: AppColors.green5,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.grey8),
        ),
      ],
    );
  }
}

class _ChartContainer extends StatelessWidget {
  final Widget child;

  const _ChartContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

