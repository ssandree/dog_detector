import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'dart:math';

/// 감정 비율 계산 유틸리티 클래스
class EmotionRatioCalculator {
  EmotionRatioCalculator._(); // private 생성자로 인스턴스화 방지

  // ========== 상수 ==========
  /// 부정 감정 리스트
  static const List<String> _negativeEmotions = [
    '불안',
    '통증',
    '흥분',
    '스트레스',
  ];
  
  /// 심각도별 가중치
  static const Map<String, double> _severityWeights = {
    'LOW': 0.3,
    'MEDIUM': 0.6,
    'HIGH': 1.0,
  };
  
  /// 비율을 색상 인덱스로 변환할 때 사용하는 배수
  static const int _ratioMultiplier = 10;

  /// 하루 이벤트 데이터 기반 부정 감정 비율 계산
  /// 
  /// [events]: 이벤트 리스트 (각 이벤트는 'emotion', 'severity' 키를 가진 Map)
  /// 반환값: 0.0 ~ 1.0 사이의 부정 감정 비율
  static double calculateNegativeRatio(List<dynamic> events) {
    if (events.isEmpty) return 0.0;

    double total = 0;
    double negativeScore = 0;

    for (final e in events) {
      final severity = e['severity'] ?? 'MEDIUM';
      final weight = _severityWeights[severity] ?? 0.6;
      total += 1;
      if (_negativeEmotions.contains(e['emotion'])) {
        negativeScore += weight;
      }
    }

    // 0~1 사이 비율로 반환
    return (negativeScore / total).clamp(0.0, 1.0);
  }

  /// 주간 통계 데이터에서 하루별 부정 감정 비율 계산
  /// 
  /// [weeklyData]: 주간 리포트 데이터 (dailyStats 키를 가진 Map)
  /// 반환값: 날짜별 부정 감정 비율 Map (예: {'10-06': 0.2, '10-07': 0.11, ...})
  static Map<String, double> calculateWeeklyRatios(Map<String, dynamic> weeklyData) {
    final dailyStats = weeklyData['dailyStats'] ?? [];
    final Map<String, double> result = {};

    for (final stat in dailyStats) {
      final bark = (stat['bark'] ?? 0).toDouble();
      final howl = (stat['howl'] ?? 0).toDouble();
      final total = max(bark + howl, 1); // 0 나누기 방지
      final negativeRatio = howl / total;
      result[stat['date']] = negativeRatio;
    }

    return result;
  }

  /// 비율(0~1)을 히트맵 색상으로 변환
  /// 
  /// [ratio]: 0.0 ~ 1.0 사이의 비율 값
  /// 반환값: AppColors.blended 배열의 색상
  static Color getColorByRatio(double ratio) {
    final index = (ratio * _ratioMultiplier).round().clamp(0, 10);
    return AppColors.blended[index];
  }
}
