import 'package:flutter/material.dart';
import 'package:dog_detect/theme/app_colors.dart';
import 'dart:math';

/// 하루 이벤트 데이터 기반 부정 감정 비율 계산
double calculateNegativeRatio(List<dynamic> events) {
   if (events.isEmpty) return 0.0;

   final negativeEmotions = ['불안', '통증', '흥분', '스트레스'];
   final severityWeights = {'LOW': 0.3, 'MEDIUM': 0.6, 'HIGH': 1.0};

   double total = 0;
   double negativeScore = 0;

   for (final e in events) {
      final severity = e['severity'] ?? 'MEDIUM';
      final weight = severityWeights[severity] ?? 0.6;
      total += 1;
      if (negativeEmotions.contains(e['emotion'])) {
         negativeScore += weight;
      }
   }

   // 0~1 사이 비율로 반환
   return (negativeScore / total).clamp(0.0, 1.0);
   }

   /// 주간 통계 데이터에서 하루별 부정 감정 비율 계산
   Map<String, double> calculateWeeklyRatios(Map<String, dynamic> weeklyData) {
   final dailyStats = weeklyData['dailyStats'] ?? [];
   final Map<String, double> result = {};

   for (final stat in dailyStats) {
      final bark = (stat['bark'] ?? 0).toDouble();
      final howl = (stat['howl'] ?? 0).toDouble();
      final total = max(bark + howl, 1); // 0 나누기 방지
      final negativeRatio = howl / total;
      result[stat['date']] = negativeRatio;
   }

   return result; // ex) {'10-06': 0.2, '10-07': 0.11, ...}
   }

  /// 비율(0~1)을 히트맵 색상으로 변환
  Color getColorByRatio(double ratio) {
    final index = (ratio * 10).round().clamp(0, 10);
    return AppColors.blended[index];
  }
