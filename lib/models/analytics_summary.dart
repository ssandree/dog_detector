// lib/models/analytics_summary.dart
// 분석 요약 데이터 모델
// - 총 분석 건수, 긍정/부정/중립 비율, 상위 감정 리스트 포함
// - 서버 응답 파싱 및 Hive 캐싱용 구조

import 'package:hive/hive.dart';

part 'analytics_summary.g.dart';

@HiveType(typeId: 30)
class AnalyticsSummary {
  @HiveField(0)
  final int total;
  @HiveField(1)
  final int positive;
  @HiveField(2)
  final int negative;
  @HiveField(3)
  final int neutral;
  @HiveField(4)
  final List<String> topEmotions;

  const AnalyticsSummary({
    required this.total,
    required this.positive,
    required this.negative,
    required this.neutral,
    required this.topEmotions,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      total: json['total'] ?? 0,
      positive: json['positive'] ?? 0,
      negative: json['negative'] ?? 0,
      neutral: json['neutral'] ?? 0,
      topEmotions: (json['top_emotions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
