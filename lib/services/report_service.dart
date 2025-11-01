import '../data/report_mock.dart';

/// 리포트 관련 데이터 서비스
class ReportService {
  /// 주간 리포트 데이터 조회
  static Future<Map<String, dynamic>> getWeeklyReport() async {
    // TODO: 실제 API 호출로 변경
    await Future.delayed(const Duration(milliseconds: 300)); // 로딩 시뮬레이션
    return Map<String, dynamic>.from(mockWeeklyReport);
  }

  /// 일일 리포트 데이터 조회
  static Future<Map<String, dynamic>> getDailyReport(DateTime date) async {
    // TODO: 실제 API 호출로 변경
    await Future.delayed(const Duration(milliseconds: 300)); // 로딩 시뮬레이션
    return Map<String, dynamic>.from(mockDailyReport);
  }

  /// 월간 리포트 데이터 조회
  static Future<Map<String, dynamic>> getMonthlyReport(int year, int month) async {
    // TODO: 실제 API 호출로 변경
    await Future.delayed(const Duration(milliseconds: 300)); // 로딩 시뮬레이션
    // mockMonthlyReport를 동적으로 수정하여 year, month 반영
    final report = Map<String, dynamic>.from(mockMonthlyReport);
    report['year'] = year;
    report['month'] = month;
    return report;
  }
}

