// lib/models/emotion_report.dart
// 감정 리포트 모델
// - 개별 감정 분석 결과(감정명, 확률, 촬영 날짜, 근거 영상 URL, 카메라 ID 등) 정의
// - Hive 어댑터 포함(로컬 캐싱 및 오프라인 조회용)

import 'package:hive/hive.dart';

part 'emotion_report.g.dart';

@HiveType(typeId: 31)
class EmotionReport {
  @HiveField(0)
  final String emotion;
  @HiveField(1)
  final double confidence;
  @HiveField(2)
  final DateTime date;
  @HiveField(3)
  final String videoUrl;
  @HiveField(4)
  final int cameraId;

  const EmotionReport({
    required this.emotion,
    required this.confidence,
    required this.date,
    required this.videoUrl,
    required this.cameraId,
  });

  factory EmotionReport.fromJson(Map<String, dynamic> json) => EmotionReport(
        emotion: json['emotion'] ?? 'unknown',
        confidence: (json['confidence'] ?? 0).toDouble(),
        date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
        videoUrl: json['video_url'] ?? '',
        cameraId: json['camera_id'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'emotion': emotion,
        'confidence': confidence,
        'date': date.toIso8601String(),
        'video_url': videoUrl,
        'camera_id': cameraId,
      };
}
