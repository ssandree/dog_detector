// lib/widgets/report/trend_chart.dart
// 감정 변화 트렌드 차트
// - 최근 일/주/월 감정 분석 결과를 LineChart로 시각화
// - 긍정/부정/중립 비율 변화를 한눈에 확인

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/analytics_bundle.dart';
import '../../core/providers/analytics_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TrendChart extends HookConsumerWidget {
  final List<TrendPoint> points;
  const TrendChart({super.key, required this.points});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedPeriodProvider);

    if (points.isEmpty) {
      return const Card(
        margin: EdgeInsets.all(12),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('트렌드 데이터가 없습니다.')),
        ),
      );
    }

    final title = switch (period) {
      ReportPeriod.daily => '최근 일간 감정 변화',
      ReportPeriod.weekly => '최근 주간 감정 변화',
      ReportPeriod.monthly => '최근 월간 감정 변화',
    };

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1.6,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i < 0 || i >= points.length) {
                            return const SizedBox.shrink();
                          }
                          final d = points[i].date;
                          return Text('${d.month}/${d.day}',
                              style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 20,
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    _buildLine(points, (p) => p.positive, Colors.green),
                    _buildLine(points, (p) => p.negative, Colors.red),
                    _buildLine(points, (p) => p.neutral, Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildLine(
    List<TrendPoint> data,
    double Function(TrendPoint) selector,
    Color color,
  ) {
    return LineChartBarData(
      isCurved: true,
      color: color,
      barWidth: 2,
      dotData: FlDotData(show: false),
      spots: [
        for (int i = 0; i < data.length; i++)
          FlSpot(i.toDouble(), selector(data[i]) * 100),
      ],
    );
  }
}
