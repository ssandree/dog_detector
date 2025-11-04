// lib/widgets/report/trend_chart.dart
// 감정 변화 트렌드 차트
// - 최근 7일 감정 분석 결과를 LineChart로 시각화
// - 긍정/부정/중립 비율 변화를 한눈에 확인 가능

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/analytics_bundle.dart';

class TrendChart extends StatelessWidget {
  final List<TrendPoint> points;

  const TrendChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Card(
        margin: EdgeInsets.all(12),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('트렌드 데이터가 없습니다.')),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '최근 7일 감정 변화 추세',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1.6,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= points.length) {
                            return const SizedBox.shrink();
                          }
                          final d = points[index].date;
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
                  lineBarsData: [
                    _buildLine(points, (p) => p.positive.toDouble(),
                        Colors.green, '긍정'),
                    _buildLine(points, (p) => p.negative.toDouble(),
                        Colors.red, '부정'),
                    _buildLine(points, (p) => p.neutral.toDouble(),
                        Colors.grey, '중립'),
                  ],
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
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
    String label,
  ) {
    return LineChartBarData(
      isCurved: true,
      color: color,
      barWidth: 2,
      dotData: FlDotData(show: false),
      spots: [
        for (int i = 0; i < data.length; i++)
          FlSpot(i.toDouble(), selector(data[i])),
      ],
    );
  }
}
