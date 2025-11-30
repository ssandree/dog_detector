// lib/features/event/providers/event_provider.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../domain/event_info.dart';

import '../data/event_service.dart';
import '../data/remote_event_service.dart';
import '../../../core/network/dio_client.dart';

final eventServiceProvider = Provider<EventService>((ref) {
  final dio = ref.watch(apiDioProvider);
  return RemoteEventService(dio);
});

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
  bool operator ==(Object other) =>
      other is PetEventsRequest &&
      other.petId == petId &&
      other.skip == skip &&
      other.limit == limit;

  @override
  int get hashCode => Object.hash(petId, skip, limit);
}

final petEventsProvider =
    FutureProvider.autoDispose.family<List<EventInfo>, PetEventsRequest>(
  (ref, request) async {
    final service = ref.watch(eventServiceProvider);
    return service.getPetEvents(
      petId: request.petId,
      skip: request.skip,
      limit: request.limit,
    );
  },
);

class DailyEventRequest {
  final int petId;
  final DateTime date;

  const DailyEventRequest({
    required this.petId,
    required this.date,
  });

  @override
  bool operator ==(Object other) =>
      other is DailyEventRequest &&
      other.petId == petId &&
      other.date.year == date.year &&
      other.date.month == date.month &&
      other.date.day == date.day;

  @override
  int get hashCode =>
      Object.hash(petId, date.year, date.month, date.day);
}

final dailyEventsProvider =
    FutureProvider.autoDispose.family<DailyPetEvents, DailyEventRequest>(
  (ref, request) async {
    final service = ref.watch(eventServiceProvider);
    return service.getDailyPetEvents(
      petId: request.petId,
      date: request.date,
    );
  },
);

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
  bool operator ==(Object other) =>
      other is MonthlyEventRequest &&
      other.petId == petId &&
      other.year == year &&
      other.month == month;

  @override
  int get hashCode => Object.hash(petId, year, month);
}

final monthlyEventsProvider =
    FutureProvider.autoDispose.family<MonthlyEventsSummary, MonthlyEventRequest>(
  (ref, request) async {
    final service = ref.watch(eventServiceProvider);
    return service.getMonthlyEvents(
      petId: request.petId,
      year: request.year,
      month: request.month,
    );
  },
);
