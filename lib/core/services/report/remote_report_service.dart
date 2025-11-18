import '../../../models/calendar_data.dart';
import 'report_service.dart';

/// Remote 리포트 서비스 구현체
/// 실제 API 호출하는 구현체
class RemoteReportService implements ReportService {
  @override
  Future<Map<String, dynamic>> getWeeklyReport(DateTime weekStartDate) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getDailyReport(DateTime date) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getMonthlyReport(int year, int month) {
    throw UnimplementedError();
  }

  @override
  Future<CalendarData> getMonthlyCalendarData(int year, int month) {
    throw UnimplementedError();
  }
}

