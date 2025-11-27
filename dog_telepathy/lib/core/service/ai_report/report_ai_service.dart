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
}
