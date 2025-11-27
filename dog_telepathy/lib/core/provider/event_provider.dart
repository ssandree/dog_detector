import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/event_info.dart';
import '../service/event/event_service.dart';
import '../service/event/mock_event_service.dart';
import '../service/event/remote_event_service.dart';

// 통계를 위한 Event, DailyEvent, monthlyEvent
/// EventService provider
final eventServiceProvider = Provider<EventService>((ref) {
  const useMock = bool.fromEnvironment(
    'USE_MOCK_EVENT_SERVICE',
    defaultValue: false,
  );

  if (useMock) {
    return MockEventService();
  }
  return RemoteEventService();
});

/// 이벤트 목록 조회 요청 파라미터
class PetEventsRequest {
  final int petId;
  final int skip;
  final int limit;

  const PetEventsRequest({
    required this.petId,
    this.skip = 0,
    this.limit = 100,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PetEventsRequest &&
        other.petId == petId &&
        other.skip == skip &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(petId, skip, limit);
}

/// 전체 이벤트 목록 Provider (GET /pets/{pet_id}/events)
final petEventsProvider =
    FutureProvider.autoDispose.family<List<EventInfo>, PetEventsRequest>(
        (ref, request) async {
  final service = ref.watch(eventServiceProvider);
  return service.getPetEvents(
    petId: request.petId,
    skip: request.skip,
    limit: request.limit,
  );
});

/// 하루 단위 이벤트 조회 요청 파라미터
class DailyEventRequest {
  final int petId;
  final DateTime date;

  const DailyEventRequest({
    required this.petId,
    required this.date,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyEventRequest &&
        other.petId == petId &&
        other.date.year == date.year &&
        other.date.month == date.month &&
        other.date.day == date.day;
  }

  @override
  int get hashCode => Object.hash(
        petId,
        date.year,
        date.month,
        date.day,
      );
}

/// 하루 단위 이벤트 Provider
final dailyEventsProvider = FutureProvider.autoDispose
    .family<DailyPetEvents, DailyEventRequest>((ref, request) async {
  final service = ref.watch(eventServiceProvider);
  return service.getDailyPetEvents(
    petId: request.petId,
    date: request.date,
  );
});

class MonthlyEventRequest {
  final int petId;
  final int year;
  final int month;

  const MonthlyEventRequest({
    required this.petId,
    required this.year,
    required this.month,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MonthlyEventRequest &&
        other.petId == petId &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode => Object.hash(petId, year, month);
}

final monthlyEventsProvider = FutureProvider.autoDispose
    .family<MonthlyEventsSummary, MonthlyEventRequest>((ref, request) async {
  final service = ref.watch(eventServiceProvider);
  return service.getMonthlyEvents(
    petId: request.petId,
    year: request.year,
    month: request.month,
  );
});


