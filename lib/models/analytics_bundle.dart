// lib/models/analytics_bundle.dart
// 분석 데이터 통합 모델
// - summary, trend, camera 세그먼트를 하나로 묶음
// - Hive 캐시 직렬화 지원

import 'package:hive/hive.dart';
import 'analytics_summary.dart';

part 'analytics_bundle.g.dart';

@HiveType(typeId: 29)
class AnalyticsBundle {
  @HiveField(0)
  final AnalyticsSummary summary;

  @HiveField(1)
  final List<TrendPoint> trend;

  @HiveField(2)
  final List<CameraStat> camera;

  const AnalyticsBundle({
    required this.summary,
    required this.trend,
    required this.camera,
  });
}

@HiveType(typeId: 32)
class TrendPoint {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final double positive;

  @HiveField(2)
  final double negative;

  @HiveField(3)
  final double neutral;

  const TrendPoint({
    required this.date,
    required this.positive,
    required this.negative,
    required this.neutral,
  });

  factory TrendPoint.fromJson(Map<String, dynamic> json) {
    return TrendPoint(
      date: DateTime.parse(json['date']),
      positive: (json['positive'] ?? 0).toDouble(),
      negative: (json['negative'] ?? 0).toDouble(),
      neutral: (json['neutral'] ?? 0).toDouble(),
    );
  }
}

@HiveType(typeId: 33)
class CameraStat {
  @HiveField(0)
  final int cameraId;

  @HiveField(1)
  final double avgScore;

  @HiveField(2)
  final int count;

  const CameraStat({
    required this.cameraId,
    required this.avgScore,
    required this.count,
  });

  factory CameraStat.fromJson(Map<String, dynamic> json) {
    return CameraStat(
      cameraId: json['camera_id'] ?? 0,
      avgScore: (json['avg_score'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }
}
