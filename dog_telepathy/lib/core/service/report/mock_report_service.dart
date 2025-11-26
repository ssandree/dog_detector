import '../../data/report_mock.dart';
import '../../exceptions.dart';
import 'report_service.dart';

/// Mock 리포트 서비스 구현체
/// API 없이도 동작하는 가짜 구현체

class MockReportService implements ReportService {
  @override
  Future<Map<String, dynamic>> getDailyReport(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final key =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    Map<String, dynamic> json;

    if (mockDailyReports.containsKey(key)) {
      json = Map<String, dynamic>.from(mockDailyReports[key]!);
    } else {
      json = Map<String, dynamic>.from(mockDailyReport);
      json["report_date"] = key;
    }

    return {
      "date": json["report_date"],
      "summary": json["summary_text"],
    };
  }
}
