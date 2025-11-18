import '../../../models/calendar_data.dart';

/// 리포트 관련 데이터 서비스 인터페이스
abstract class ReportService {
  /// 주간 리포트 데이터 조회
  /// 
  /// [weekStartDate]: 주 시작일 (월요일)
  /// 반환값: 해당 주의 리포트 데이터
  Future<Map<String, dynamic>> getWeeklyReport(DateTime weekStartDate);

  /// 일일 리포트 데이터 조회
  Future<Map<String, dynamic>> getDailyReport(DateTime date);

  /// 월간 리포트 데이터 조회
  Future<Map<String, dynamic>> getMonthlyReport(int year, int month);

  /// 캘린더 화면용 월간 데이터 조회
  /// 
  /// [year]: 연도
  /// [month]: 월 (1-12)
  /// 반환값: CalendarData 객체
  /// 예외: NetworkException, DataException
  Future<CalendarData> getMonthlyCalendarData(int year, int month);
}

