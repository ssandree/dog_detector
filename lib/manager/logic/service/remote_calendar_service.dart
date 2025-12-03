import 'package:dio/dio.dart';

import '../../../core/error/exceptions.dart';
import 'event_service.dart';
import 'remote_event_service.dart';

/// 실제 API를 통해 월간 이벤트를 조회하는 서비스
/// RemoteEventService를 재사용하여 중복 코드 제거
class RemoteCalendarService {
  final RemoteEventService _eventService;
  
  RemoteCalendarService(Dio dio) : _eventService = RemoteEventService(dio);

  Future<MonthlyCalendarResponse> getMonthlyEvents({
    required int petId,
    required int year,
    required int month,
  }) async {
    try {
      // RemoteEventService의 getMonthlyEvents를 사용하여 이벤트 리스트 가져오기
      final monthlySummary = await _eventService.getMonthlyEvents(
        petId: petId,
        year: year,
        month: month,
      );

      // MonthlyEventsSummary를 MonthlyCalendarResponse로 변환
      final days = <int, MonthlyDayStat>{};
      monthlySummary.days.forEach((day, stat) {
        days[day] = MonthlyDayStat(
          happy: stat.happy,
          calm: stat.calm,
          angry: stat.angry,
          fear: stat.fear,
          totalEvents: stat.totalEvents,
          score: stat.score,
        );
      });

      return MonthlyCalendarResponse(
        petId: petId,
        year: year,
        month: month,
        days: days,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('월간 이벤트 조회 중 오류가 발생했습니다', e);
    }
  }
}
