import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/calendar_data.dart';
import '../theme/app_colors.dart';

/// Mock 데이터를 CalendarData로 변환하는 헬퍼 클래스
class CalendarMockConverter {
  CalendarMockConverter._();

  /// Mock 데이터의 color 문자열을 Color 객체로 변환
  static Color _getColorByName(String colorName) {
    switch (colorName) {
      case 'green1':
        return AppColors.green1;
      case 'green2':
        return AppColors.green2;
      case 'green3':
        return AppColors.green3;
      case 'green5':
        return AppColors.green5;
      case 'green8':
        return AppColors.green8;
      case 'coral1':
        return AppColors.coral1;
      case 'coral2':
        return AppColors.coral2;
      case 'coral3':
        return AppColors.coral3;
      case 'coral4':
        return AppColors.coral4;
      case 'grey4':
        return AppColors.grey4;
      case 'error':
        return AppColors.error;
      default:
        return AppColors.grey4;
    }
  }

  /// IconData 이름을 IconData로 변환
  static IconData _getIconByName(String iconName) {
    switch (iconName) {
      case 'warning_amber_rounded':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info;
    }
  }

  /// Mock 데이터에서 CalendarData 생성
  static CalendarData fromMockData(Map<String, dynamic> mockData) {
    final calendarData = mockData['calendarData'] as Map<String, dynamic>;

    // Rank Stats
    final rankStats = (calendarData['rankStats'] as List)
        .map((item) => RankChipData(
              rankLabel: 'Top ${item['rank']}',
              text: '${item['emotion']} ${item['count']}회',
              backgroundColor: _getColorByName(item['bgColor'] as String),
              borderColor: _getColorByName(item['borderColor'] as String),
            ))
        .toList();

    // Pie Chart Data
    final pieChartData = calendarData['pieChartData'] as List;
    final pieChartSections = pieChartData.map((item) {
      final percentage = item['percentage'] as int;
      final color = _getColorByName(item['color'] as String);
      return PieChartSectionData(
        color: color,
        value: percentage.toDouble(),
        title: '$percentage%',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color == AppColors.grey4 ? AppColors.black : AppColors.white,
        ),
      );
    }).toList();

    final pieChartLegends = pieChartData
        .map((item) => LegendItemData(
              color: _getColorByName(item['color'] as String),
              label: item['emotion'] as String,
            ))
        .toList();

    // Emotion Ratio
    final emotionRatioData = calendarData['emotionRatio'] as Map<String, dynamic>;
    final emotionRatio = EmotionRatioData(
      negativePercent: emotionRatioData['negativePercent'] as int,
      positivePercent: emotionRatioData['positivePercent'] as int,
      negativeColor: _getColorByName(emotionRatioData['negativeColor'] as String),
      positiveColor: _getColorByName(emotionRatioData['positiveColor'] as String),
    );

    // Health Alert
    final healthAlertData = calendarData['healthAlert'] as Map<String, dynamic>;
    final healthAlert = HealthAlertData(
      message: healthAlertData['message'] as String,
      detectionCount: healthAlertData['detectionCount'] as String,
      countLabel: healthAlertData['countLabel'] as String,
      timeSlots: (healthAlertData['timeSlots'] as List)
          .map((item) => TimeSlotData(
                time: item['time'] as String,
                count: item['count'] as String,
                color: _getColorByName(item['color'] as String),
              ))
          .toList(),
      iconName: healthAlertData['icon'] as String,
      backgroundColor: _getColorByName(healthAlertData['bgColor'] as String),
      iconColor: _getColorByName(healthAlertData['iconColor'] as String),
      textColor: _getColorByName(healthAlertData['textColor'] as String),
    );

    // AI Report
    final aiReportData = calendarData['aiReport'] as Map<String, dynamic>;
    final aiReport = AiReportData(
      title: aiReportData['title'] as String,
      subtitle: aiReportData['subtitle'] as String,
      statusLabel: aiReportData['statusLabel'] as String,
      statusColor: _getColorByName(aiReportData['statusColor'] as String),
      analysisTexts: (aiReportData['analysisTexts'] as List).cast<String>(),
      guideItems: (aiReportData['guideItems'] as List).cast<String>(),
    );

    // Monthly Trend
    final monthlyTrendData = calendarData['monthlyTrend'] as Map<String, dynamic>;
    final radarEntriesData = monthlyTrendData['radarEntries'] as List;
    final radarEntries = radarEntriesData
        .map((item) => RadarEntry(value: (item['value'] as num).toDouble()))
        .toList();
    final radarTitles = radarEntriesData.map((item) => item['label'] as String).toList();
    final monthlyTrend = MonthlyTrendData(
      radarEntries: radarEntries,
      radarTitles: radarTitles,
    );

    // Monthly Summary
    final monthlySummaryData = calendarData['monthlySummary'] as Map<String, dynamic>;
    final monthlySummary = MonthlySummaryData(
      summaryText: monthlySummaryData['summaryText'] as String,
      bulletPoints: (monthlySummaryData['bulletPoints'] as List).cast<String>(),
    );

    return CalendarData(
      rankStats: rankStats,
      pieChartSections: pieChartSections,
      pieChartLegends: pieChartLegends,
      emotionRatio: emotionRatio,
      healthAlert: healthAlert,
      aiReport: aiReport,
      monthlyTrend: monthlyTrend,
      monthlySummary: monthlySummary,
    );
  }

  /// 분리된 캘린더 전용 목업(Map<String,dynamic>)에서 CalendarData 생성
  static CalendarData fromCalendarOnly(Map<String, dynamic> calendarData) {
    // Rank Stats
    final rankStats = (calendarData['rankStats'] as List)
        .map((item) => RankChipData(
              rankLabel: 'Top ${item['rank']}',
              text: '${item['emotion']} ${item['count']}회',
              backgroundColor: _getColorByName(item['bgColor'] as String),
              borderColor: _getColorByName(item['borderColor'] as String),
            ))
        .toList();

    // Pie Chart Data
    final pieChartData = calendarData['pieChartData'] as List;
    final pieChartSections = pieChartData.map((item) {
      final percentage = item['percentage'] as int;
      final color = _getColorByName(item['color'] as String);
      return PieChartSectionData(
        color: color,
        value: percentage.toDouble(),
        title: '$percentage%',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color == AppColors.grey4 ? AppColors.black : AppColors.white,
        ),
      );
    }).toList();

    final pieChartLegends = pieChartData
        .map((item) => LegendItemData(
              color: _getColorByName(item['color'] as String),
              label: item['emotion'] as String,
            ))
        .toList();

    // Emotion Ratio
    final emotionRatioData = calendarData['emotionRatio'] as Map<String, dynamic>;
    final emotionRatio = EmotionRatioData(
      negativePercent: emotionRatioData['negativePercent'] as int,
      positivePercent: emotionRatioData['positivePercent'] as int,
      negativeColor: _getColorByName(emotionRatioData['negativeColor'] as String),
      positiveColor: _getColorByName(emotionRatioData['positiveColor'] as String),
    );

    // Health Alert
    final healthAlertData = calendarData['healthAlert'] as Map<String, dynamic>;
    final healthAlert = HealthAlertData(
      message: healthAlertData['message'] as String,
      detectionCount: healthAlertData['detectionCount'] as String,
      countLabel: healthAlertData['countLabel'] as String,
      timeSlots: (healthAlertData['timeSlots'] as List)
          .map((item) => TimeSlotData(
                time: item['time'] as String,
                count: item['count'] as String,
                color: _getColorByName(item['color'] as String),
              ))
          .toList(),
      iconName: healthAlertData['icon'] as String,
      backgroundColor: _getColorByName(healthAlertData['bgColor'] as String),
      iconColor: _getColorByName(healthAlertData['iconColor'] as String),
      textColor: _getColorByName(healthAlertData['textColor'] as String),
    );

    // AI Report
    final aiReportData = calendarData['aiReport'] as Map<String, dynamic>;
    final aiReport = AiReportData(
      title: aiReportData['title'] as String,
      subtitle: aiReportData['subtitle'] as String,
      statusLabel: aiReportData['statusLabel'] as String,
      statusColor: _getColorByName(aiReportData['statusColor'] as String),
      analysisTexts: (aiReportData['analysisTexts'] as List).cast<String>(),
      guideItems: (aiReportData['guideItems'] as List).cast<String>(),
    );

    // Monthly Trend
    final monthlyTrendData = calendarData['monthlyTrend'] as Map<String, dynamic>;
    final radarEntriesData = monthlyTrendData['radarEntries'] as List;
    final radarEntries = radarEntriesData
        .map((item) => RadarEntry(value: (item['value'] as num).toDouble()))
        .toList();
    final radarTitles = radarEntriesData.map((item) => item['label'] as String).toList();
    final monthlyTrend = MonthlyTrendData(
      radarEntries: radarEntries,
      radarTitles: radarTitles,
    );

    // Monthly Summary
    final monthlySummaryData = calendarData['monthlySummary'] as Map<String, dynamic>;
    final monthlySummary = MonthlySummaryData(
      summaryText: monthlySummaryData['summaryText'] as String,
      bulletPoints: (monthlySummaryData['bulletPoints'] as List).cast<String>(),
    );

    return CalendarData(
      rankStats: rankStats,
      pieChartSections: pieChartSections,
      pieChartLegends: pieChartLegends,
      emotionRatio: emotionRatio,
      healthAlert: healthAlert,
      aiReport: aiReport,
      monthlyTrend: monthlyTrend,
      monthlySummary: monthlySummary,
    );
  }
}

