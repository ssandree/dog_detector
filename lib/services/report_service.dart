import '../data/report_mock.dart';
import '../data/calendar_mock_converter.dart';
import '../models/calendar_data.dart';
import '../core/exceptions.dart';

/// 리포트 관련 데이터 서비스
class ReportService {
  /// 주간 리포트 데이터 조회
  Future<Map<String, dynamic>> getWeeklyReport() async {
    try {
      // TODO: 실제 API 호출로 변경
      await Future.delayed(const Duration(milliseconds: 300)); // 로딩 시뮬레이션
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
      
      // Mock 데이터에서 월간 리포트 가져오기
      final report = Map<String, dynamic>.from(mockMonthlyReport);
      report['year'] = year;
      report['month'] = month;
      
      // CalendarData로 변환
      return CalendarMockConverter.fromMockData(report);
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

