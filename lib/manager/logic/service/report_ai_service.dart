// lib/manager/logic/service/report_ai_service.dart
/// 리포트 관련 데이터 서비스 인터페이스
abstract class ReportService {
  /// 특정 날짜의 일일 리포트 조회 또는 생성
  ///
  /// 반환값은 다음 정보를 포함:
  /// {
  ///   "date": "YYYY-MM-DD",
  ///   "summary": "string"
  /// }
  Future<Map<String, dynamic>> getDailyReport(DateTime date);

  /// 특정 월의 월간 리포트 조회
  ///
  /// 옵션 1: year, month가 모두 null이면 전체 리포트 최신순 반환
  /// 옵션 2: year, month를 입력하면 해당 월 리포트만 반환
  ///
  /// 반환값은 배열 형태:
  /// [
  ///   {
  ///     "pet_id": 0,
  ///     "report_month": "YYYY-MM",
  ///     "summary_text": "string",
  ///     "report_id": 0,
  ///     "created_at": "2025-12-04T12:04:49.465Z"
  ///   }
  /// ]
  Future<List<Map<String, dynamic>>> getMonthlyReport(int? year, int? month);

  /// 위클리 리포트 조회
  ///
  /// 옵션 1: year, month, week가 모두 null이면 전체 리포트 최신순 반환
  /// 옵션 2: year, month, week를 모두 입력하면 해당 주차 리포트만 반환
  ///
  /// 반환값은 배열 형태:
  /// [
  ///   {
  ///     "pet_id": 0,
  ///     "start_date": "YYYY-MM-DD",
  ///     "end_date": "YYYY-MM-DD",
  ///     "summary_text": "string",
  ///     "report_id": 0,
  ///     "created_at": "2025-12-07T12:26:01.340Z"
  ///   }
  /// ]
  Future<List<Map<String, dynamic>>> getWeeklyReport(int? year, int? month, int? week);
}
