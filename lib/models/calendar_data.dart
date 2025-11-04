import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';

/// 캘린더 화면용 월간 데이터 모델
class CalendarData {
  final List<RankChipData> rankStats;
  final List<PieChartSectionData> pieChartSections;
  final List<LegendItemData> pieChartLegends;
  final EmotionRatioData emotionRatio;
  final HealthAlertData healthAlert;
  final AiReportData aiReport;
  final MonthlyTrendData monthlyTrend;
  final MonthlySummaryData monthlySummary;

  const CalendarData({
    required this.rankStats,
    required this.pieChartSections,
    required this.pieChartLegends,
    required this.emotionRatio,
    required this.healthAlert,
    required this.aiReport,
    required this.monthlyTrend,
    required this.monthlySummary,
  });
}

/// 순위 칩 데이터 (RankChipData와 동일한 구조)
class RankChipData {
  final String rankLabel;
  final String text;
  final Color backgroundColor;
  final Color borderColor;

  const RankChipData({
    required this.rankLabel,
    required this.text,
    required this.backgroundColor,
    required this.borderColor,
  });
}

/// 범례 아이템 데이터 (LegendItemData와 동일한 구조)
class LegendItemData {
  final Color color;
  final String label;

  const LegendItemData({
    required this.color,
    required this.label,
  });
}

/// 시간대 데이터 (TimeSlotData와 동일한 구조)
class TimeSlotData {
  final String time;
  final String count;
  final Color color;

  const TimeSlotData({
    required this.time,
    required this.count,
    required this.color,
  });
}

/// 감정 비율 바 데이터
class EmotionRatioData {
  final int negativePercent;
  final int positivePercent;
  final Color negativeColor;
  final Color positiveColor;

  const EmotionRatioData({
    required this.negativePercent,
    required this.positivePercent,
    required this.negativeColor,
    required this.positiveColor,
  });
}

/// 건강 알림 데이터
class HealthAlertData {
  final String message;
  final String detectionCount;
  final String countLabel;
  final List<TimeSlotData> timeSlots;
  final String iconName;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const HealthAlertData({
    required this.message,
    required this.detectionCount,
    required this.countLabel,
    required this.timeSlots,
    required this.iconName,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
  });
}

/// AI 리포트 데이터
class AiReportData {
  final String title;
  final String subtitle;
  final String statusLabel;
  final Color statusColor;
  final List<String> analysisTexts;
  final List<String> guideItems;

  const AiReportData({
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.statusColor,
    required this.analysisTexts,
    required this.guideItems,
  });
}

/// 월간 트렌드 분석 데이터
class MonthlyTrendData {
  final List<RadarEntry> radarEntries;
  final List<String> radarTitles;

  const MonthlyTrendData({
    required this.radarEntries,
    required this.radarTitles,
  });
}

/// 월간 요약 데이터
class MonthlySummaryData {
  final String summaryText;
  final List<String> bulletPoints;

  const MonthlySummaryData({
    required this.summaryText,
    required this.bulletPoints,
  });
}

