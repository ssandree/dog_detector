// lib/features/event/data/remote_event_service.dart

import 'package:dio/dio.dart';
import '../../../core/error/exceptions.dart';
import '../../event/domain/event_info.dart';
import 'event_service.dart';

class RemoteEventService implements EventService {
  final Dio _dio;

  RemoteEventService(this._dio);

  @override
  Future<List<EventInfo>> getPetEvents({
    required int petId,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final res = await _dio.get(
        '/pets/$petId/events',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      final list = res.data as List;
      return list
          .map((e) => EventInfo.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, '이벤트 목록 불러오기 실패');
    }
  }

  @override
  Future<DailyPetEvents> getDailyPetEvents({
    required int petId,
    required DateTime date,
  }) async {
    try {
      final res = await _dio.get(
        '/pets/$petId/events/daily',
        queryParameters: {
          'target_date': _format(date),
        },
      );

      final list = res.data as List;
      return DailyPetEvents(
        petId: petId,
        date: DateTime(date.year, date.month, date.day),
        events: list
            .map((e) => EventInfo.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    } on DioException catch (e) {
      throw _handleDioError(e, '하루 이벤트 불러오기 실패');
    }
  }

  @override
  Future<MonthlyEventsSummary> getMonthlyEvents({
    required int petId,
    required int year,
    required int month,
  }) async {
    try {
      final res = await _dio.get(
        '/pets/$petId/events/monthly',
        queryParameters: {
          'year': year,
          'month': month,
        },
      );

      final list = res.data as List;

      return _aggregateMonthly(
        petId: petId,
        year: year,
        month: month,
        events: list
            .map((e) => EventInfo.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    } on DioException catch (e) {
      throw _handleDioError(e, '월간 이벤트 불러오기 실패');
    }
  }

  AppException _handleDioError(DioException e, String msg) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException('서버 연결 시간이 초과되었습니다', e);
    }
    if (e.type == DioExceptionType.connectionError) {
      return NetworkException('서버에 연결할 수 없습니다', e);
    }
    if (e.response != null) {
      final code = e.response!.statusCode;
      if (code == 401) return AuthException('인증 필요', e);
      if (code == 404) return NetworkException('리소스 없음', e);
      if (code == 422) {
        final detail = e.response?.data['detail'] as List?;
        final msg = detail != null && detail.isNotEmpty
            ? detail.first['msg'] ?? "입력 오류"
            : "입력 오류";
        return ValidationException(msg);
      }
      if (code != null && code >= 500) {
        return NetworkException('서버 오류', e);
      }
    }
    return NetworkException(msg, e);
  }

  String _format(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final dy = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$dy';
  }

  MonthlyEventsSummary _aggregateMonthly({
    required int petId,
    required int year,
    required int month,
    required List<EventInfo> events,
  }) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final map = {
      for (int i = 1; i <= daysInMonth; i++) i: _DayAccumulator(),
    };

    for (final event in events) {
      if (event.startTime.year == year &&
          event.startTime.month == month) {
        map[event.startTime.day]!.register(event);
      }
    }

    return MonthlyEventsSummary(
      petId: petId,
      year: year,
      month: month,
      days: {
        for (final entry in map.entries) entry.key: entry.value.toStat()
      },
    );
  }
}

class _DayAccumulator {
  int happy = 0, calm = 0, angry = 0, fear = 0;

  void register(EventInfo e) {
    final em = (e.finalEmotion ?? "").toLowerCase().trim();
    if (_happy.contains(em)) happy++;
    else if (_calm.contains(em)) calm++;
    else if (_angry.contains(em)) angry++;
    else if (_fear.contains(em)) fear++;
    else calm++;
  }

  MonthlyEventStat toStat() {
    final total = happy + calm + angry + fear;
    final score = (happy + calm) - (angry + fear);
    return MonthlyEventStat(
      happy: happy,
      calm: calm,
      angry: angry,
      fear: fear,
      totalEvents: total,
      score: score,
    );
  }
}

const _happy = {'happy', '행복', '즐거움', '기쁨'};
const _calm = {'calm', '평온', '안정', '편안'};
const _angry = {'angry', '화남', '분노'};
const _fear = {'fear', '불안', '두려움', '경계'};
