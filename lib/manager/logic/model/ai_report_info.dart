// lib/manager/logic/model/ai_report_info.dart

/// 하루 AI 리포트 요청 파라미터
class DailyReportRequest {
  final int petId;
  final DateTime date;

  const DailyReportRequest({
    required this.petId,
    required this.date,
  });

  DateTime get normalizedDate => DateTime(date.year, date.month, date.day);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyReportRequest &&
        other.petId == petId &&
        other.normalizedDate == normalizedDate;
  }

  @override
  int get hashCode => Object.hash(
        petId,
        normalizedDate.year,
        normalizedDate.month,
        normalizedDate.day,
      );
}

/// AI 리포트 응답 모델
class DailyAiReport {
  final int petId;
  final DateTime date;
  final String summary;
  final DateTime? createdAt;

  const DailyAiReport({
    required this.petId,
    required this.date,
    required this.summary,
    this.createdAt,
  });

  bool get hasSummary => summary.trim().isNotEmpty;
}

/// 월간 AI 리포트 요청 파라미터
class MonthlyReportRequest {
  final int petId;
  final int? year;
  final int? month;

  const MonthlyReportRequest({
    required this.petId,
    this.year,
    this.month,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MonthlyReportRequest &&
        other.petId == petId &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode => Object.hash(petId, year, month);
}

/// 월간 AI 리포트 응답 모델
class MonthlyAiReport {
  final int petId;
  final String reportMonth; // "YYYY-MM" 형식
  final String summary;
  final int reportId;
  final DateTime? createdAt;

  const MonthlyAiReport({
    required this.petId,
    required this.reportMonth,
    required this.summary,
    required this.reportId,
    this.createdAt,
  });

  bool get hasSummary => summary.trim().isNotEmpty;
}

/// 위클리 AI 리포트 요청 파라미터
class WeeklyReportRequest {
  final int petId;
  final int? year;
  final int? month;
  final int? week;

  const WeeklyReportRequest({
    required this.petId,
    this.year,
    this.month,
    this.week,
  });

  /// DateTime에서 year, month, week를 계산하는 생성자
  factory WeeklyReportRequest.fromDate({
    required int petId,
    required DateTime date,
  }) {
    // 주간 번호 계산 (월의 첫 번째 월요일부터 시작)
    final weekday = date.weekday; // 1(월) ~ 7(일)
    final weekStart = date.subtract(Duration(days: weekday - 1));
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final firstMonday = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
    final daysDiff = weekStart.difference(firstMonday).inDays;
    final weekNumber = (daysDiff ~/ 7) + 1;

    return WeeklyReportRequest(
      petId: petId,
      year: date.year,
      month: date.month,
      week: weekNumber,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeeklyReportRequest &&
        other.petId == petId &&
        other.year == year &&
        other.month == month &&
        other.week == week;
  }

  @override
  int get hashCode => Object.hash(petId, year, month, week);
}

/// 위클리 AI 리포트 응답 모델
class WeeklyAiReport {
  final int petId;
  final DateTime startDate;
  final DateTime endDate;
  final String summary;
  final int reportId;
  final DateTime? createdAt;

  const WeeklyAiReport({
    required this.petId,
    required this.startDate,
    required this.endDate,
    required this.summary,
    required this.reportId,
    this.createdAt,
  });

  bool get hasSummary => summary.trim().isNotEmpty;
}

