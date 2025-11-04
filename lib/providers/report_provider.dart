import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/report_service.dart';
import '../models/calendar_data.dart';

/// ReportService Provider
final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService();
});

/// 주간 리포트 데이터 상태를 관리하는 Provider
final weeklyReportProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final reportService = ref.watch(reportServiceProvider);
  return await reportService.getWeeklyReport();
});

/// 일일 리포트 데이터 상태를 관리하는 Provider
final dailyReportProvider = FutureProvider.family<Map<String, dynamic>, DateTime>(
  (ref, date) async {
    final reportService = ref.watch(reportServiceProvider);
    return await reportService.getDailyReport(date);
  },
);

/// 월간 리포트 데이터 상태를 관리하는 Provider
final monthlyReportProvider = FutureProvider.family<Map<String, dynamic>, ({int year, int month})>(
  (ref, params) async {
    final reportService = ref.watch(reportServiceProvider);
    return await reportService.getMonthlyReport(params.year, params.month);
  },
);

/// 캘린더 화면용 월간 데이터 상태를 관리하는 Provider
final monthlyCalendarProvider = FutureProvider.family<CalendarData, ({int year, int month})>(
  (ref, params) async {
    final reportService = ref.watch(reportServiceProvider);
    return await reportService.getMonthlyCalendarData(params.year, params.month);
  },
);

