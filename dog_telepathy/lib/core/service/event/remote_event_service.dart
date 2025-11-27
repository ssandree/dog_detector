import 'package:dio/dio.dart';
import '../../models/event_info.dart';
import '../../exceptions.dart';
import '../../config/api_config.dart';
import 'event_service.dart';

/// Remote 이벤트 서비스 구현체
/// 실제 API 호출하는 구현체
class RemoteEventService implements EventService {
  final Dio _dio;

  RemoteEventService() : _dio = ApiConfig.createDio();

  @override
  Future<List<EventInfo>> getPetEvents({
    required int petId,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        '/pets/$petId/events',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => EventInfo.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      } else {
        throw NetworkException('이벤트 목록을 불러오는데 실패했습니다');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, '이벤트 목록을 불러오는데 실패했습니다');
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '이벤트 목록을 불러오는데 실패했습니다',
        e,
      );
    }
  }

  @override
  Future<DailyPetEvents> getDailyPetEvents({
    required int petId,
    required DateTime date,
  }) async {
    try {
      final response = await _dio.get(
        '/pets/$petId/events/daily',
        queryParameters: {
          'target_date': _formatDate(date),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> raw = response.data as List<dynamic>;
        final events = raw
            .map((json) => EventInfo.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        final normalized = DateTime(date.year, date.month, date.day);
        return DailyPetEvents(
          petId: petId,
          date: normalized,
          events: events,
        );
      } else {
        throw NetworkException('하루 단위 이벤트를 불러오는데 실패했습니다');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, '하루 단위 이벤트를 불러오는데 실패했습니다');
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '하루 단위 이벤트를 불러오는데 실패했습니다',
        e,
      );
    }
  }

  @override
  Future<MonthlyEventsSummary> getMonthlyEvents({
    required int petId,
    required int year,
    required int month,
  }) async {
    try {
      final response = await _dio.get(
        '/pets/$petId/events/monthly',
        queryParameters: {
          'year': year,
          'month': month,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> raw = response.data as List<dynamic>;
        final events = raw
            .map((json) => EventInfo.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        return _aggregateMonthly(
          petId: petId,
          year: year,
          month: month,
          events: events,
        );
      } else {
        throw NetworkException('월간 이벤트를 불러오는데 실패했습니다');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, '월간 이벤트를 불러오는데 실패했습니다');
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '월간 이벤트를 불러오는데 실패했습니다',
        e,
      );
    }
  }

  /// DioException을 AppException으로 변환
  AppException _handleDioError(DioException e, String defaultMessage) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException('서버 연결 시간이 초과되었습니다', e);
    } else if (e.type == DioExceptionType.connectionError) {
      return NetworkException('서버에 연결할 수 없습니다', e);
    } else if (e.response != null) {
      final statusCode = e.response!.statusCode;
      if (statusCode == 401) {
        return AuthException('인증이 필요합니다. 다시 로그인해주세요', e);
      } else if (statusCode == 404) {
        return NetworkException('요청한 리소스를 찾을 수 없습니다', e);
      } else if (statusCode == 422) {
        // Validation Error
        final detail = e.response?.data['detail'] as List?;
        final errorMessage = detail?.isNotEmpty == true
            ? detail![0]['msg'] as String? ?? '입력값을 확인해주세요'
            : '입력값을 확인해주세요';
        return ValidationException(errorMessage);
      } else if (statusCode! >= 500) {
        return NetworkException('서버 오류가 발생했습니다', e);
      }
    }
    return NetworkException(defaultMessage, e);
  }

  MonthlyEventsSummary _aggregateMonthly({
    required int petId,
    required int year,
    required int month,
    required List<EventInfo> events,
  }) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final Map<int, _DayAccumulator> buffers = {
      for (int day = 1; day <= daysInMonth; day++) day: _DayAccumulator(),
    };

    for (final event in events) {
      if (event.startTime.year != year || event.startTime.month != month) {
        continue;
      }
      final buffer = buffers[event.startTime.day]!;
      buffer.register(event);
    }

    final days = <int, MonthlyEventStat>{};
    buffers.forEach((day, buffer) {
      days[day] = buffer.toStat();
    });

    return MonthlyEventsSummary(
      petId: petId,
      year: year,
      month: month,
      days: days,
    );
  }

  String _formatDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '${normalized.year}-$month-$day';
  }
}

class _DayAccumulator {
  int happy = 0;
  int calm = 0;
  int angry = 0;
  int fear = 0;

  void register(EventInfo event) {
    final normalizedEmotion =
        (event.finalEmotion ?? '').trim().toLowerCase();

    if (_happySet.contains(normalizedEmotion)) {
      happy += 1;
    } else if (_calmSet.contains(normalizedEmotion)) {
      calm += 1;
    } else if (_angrySet.contains(normalizedEmotion)) {
      angry += 1;
    } else if (_fearSet.contains(normalizedEmotion)) {
      fear += 1;
    } else {
      calm += 1;
    }
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

const Set<String> _happySet = {
  'happy',
  '행복',
  '기쁨',
  '즐거움',
};

const Set<String> _calmSet = {
  'calm',
  '평온',
  '안정',
  '편안',
};

const Set<String> _angrySet = {
  'angry',
  '화남',
  '분노',
};

const Set<String> _fearSet = {
  'fear',
  '불안',
  '두려움',
  '경계',
};

