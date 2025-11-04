// lib/widgets/report/camera_distribution_chart.dart
// 카메라별 감정 분석 분포 차트
// - 각 카메라의 평균 점수 및 분석 건수 시각화
// - BarChart를 이용해 감정 인식 정확도 비교

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/analytics_bundle.dart';

class CameraDistributionChart extends StatelessWidget {
  final List<CameraStat> cameraStats;

  const CameraDistributionChart({super.key, required this.cameraStats});

  @override
  Widget build(BuildContext context) {
    if (cameraStats.isEmpty) {
      return const Card(
        margin: EdgeInsets.all(12),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('카메라별 통계 데이터가 없습니다.')),
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
              '카메라별 감정 분석 분포',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    for (final c in cameraStats)
                      BarChartGroupData(
                        x: c.cameraId,
                        barRods: [
                          BarChartRodData(
                            toY: c.avgScore,
                            width: 14,
                            color: Colors.blueAccent,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                          ),
                        ],
                      ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) =>
                            Text('Cam ${v.toInt()}',
                                style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (v, _) =>
                            Text(v.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '총 ${cameraStats.fold<int>(0, (p, e) => p + e.count)}건 분석됨',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
