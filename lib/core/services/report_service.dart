import '../../data/report_mock.dart';
import '../../data/calendar_data_mock.dart';
import '../../data/calendar_mock_converter.dart';
import '../../models/calendar_data.dart';
import '../exceptions.dart';

/// 리포트 관련 데이터 서비스
class ReportService {
  /// 주간 리포트 데이터 조회
  /// 
  /// [weekStartDate]: 주 시작일 (월요일)
  /// 반환값: 해당 주의 리포트 데이터
  Future<Map<String, dynamic>> getWeeklyReport(DateTime weekStartDate) async {
    try {
      // TODO: 실제 API 호출로 변경
      await Future.delayed(const Duration(milliseconds: 300)); // 로딩 시뮬레이션
      
      // 날짜를 'YYYY-MM-DD' 형식으로 변환
      final dateKey = '${weekStartDate.year}-${weekStartDate.month.toString().padLeft(2, '0')}-${weekStartDate.day.toString().padLeft(2, '0')}';
      
      // mockWeeklyReports에서 해당 주의 데이터 찾기
      if (mockWeeklyReports.containsKey(dateKey)) {
        return Map<String, dynamic>.from(mockWeeklyReports[dateKey]!);
      }
      
      // 데이터가 없으면 기본 리포트 반환 (하위 호환성)
      return Map<String, dynamic>.from(mockWeeklyReport);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('주간 리포트 데이터를 불러오는데 실패했습니다', e);
    }
  }

  /// 일일 리포트 데이터 조회
  Future<Map<String, dynamic>> getDailyReport(DateTime date) async {
    try {
      // TODO: 실제 API 호출로 변경
      await Future.delayed(const Duration(milliseconds: 300)); // 로딩 시뮬레이션
      
      // 날짜를 'YYYY-MM-DD' 형식으로 변환
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // mockDailyReports에서 해당 날짜의 데이터 찾기
      if (mockDailyReports.containsKey(dateKey)) {
        return Map<String, dynamic>.from(mockDailyReports[dateKey]!);
      }
      
      // 데이터가 없으면 기본 리포트 반환 (하위 호환성)
      return Map<String, dynamic>.from(mockDailyReport);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('일일 리포트 데이터를 불러오는데 실패했습니다', e);
    }
  }

  /// 월간 리포트 데이터 조회
  Future<Map<String, dynamic>> getMonthlyReport(int year, int month) async {
    try {
      // TODO: 실제 API 호출로 변경
      await Future.delayed(const Duration(milliseconds: 300)); // 로딩 시뮬레이션
      // mockMonthlyReport를 동적으로 수정하여 year, month 반영
      final report = Map<String, dynamic>.from(mockMonthlyReport);
      report['year'] = year;
      report['month'] = month;
      return report;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('월간 리포트 데이터를 불러오는데 실패했습니다', e);
    }
  }

  /// 캘린더 화면용 월간 데이터 조회
  /// 
  /// [year]: 연도
  /// [month]: 월 (1-12)
  /// 반환값: CalendarData 객체
  /// 예외: NetworkException, DataException
  Future<CalendarData> getMonthlyCalendarData(int year, int month) async {
    try {
      // TODO: 실제 API 호출로 변경
      await Future.delayed(const Duration(milliseconds: 300)); // 로딩 시뮬레이션
      
      // CalendarData 모델로 변환 (분리된 캘린더 목업 사용)
      final calendarData = Map<String, dynamic>.from(mockCalendarData);
      return CalendarMockConverter.fromCalendarOnly(calendarData);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '캘린더 데이터를 불러오는데 실패했습니다',
        e,
      );
    }
  }
}

