import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/pet_info.dart';
import '../service/calendar/mock_calendar_service.dart';
import '../service/calendar/remote_calendar_service.dart';
import 'current_pet_provider.dart';

// 캘린더 UI를 나타내기 위한 monthlyEvent들
final calendarServiceProvider = Provider<dynamic>((ref) {
  const useMock = bool.fromEnvironment('USE_MOCK_CALENDAR_SERVICE', defaultValue: false);
  return useMock ? MockCalendarService() : RemoteCalendarService();
});

final calendarProvider =
    NotifierProvider<CalendarNotifier, CalendarState>(CalendarNotifier.new);

class CalendarState {
  final int petId;
  final int year;
  final int month;
  final AsyncValue<MonthlyCalendarResponse> monthlyData;

  const CalendarState({
    required this.petId,
    required this.year,
    required this.month,
    required this.monthlyData,
  });

  factory CalendarState.initial({
    required int petId,
    required DateTime date,
  }) {
    return CalendarState(
      petId: petId,
      year: date.year,
      month: date.month,
      monthlyData: const AsyncValue.loading(),
    );
  }

  CalendarState copyWith({
    int? petId,
    int? year,
    int? month,
    AsyncValue<MonthlyCalendarResponse>? monthlyData,
  }) {
    return CalendarState(
      petId: petId ?? this.petId,
      year: year ?? this.year,
      month: month ?? this.month,
      monthlyData: monthlyData ?? this.monthlyData,
    );
  }
}

class CalendarNotifier extends Notifier<CalendarState> {
  late final dynamic _service;

  @override
  CalendarState build() {
    _service = ref.watch(calendarServiceProvider);
    final now = DateTime.now();
    final currentPet = ref.watch(currentPetProvider);
    final petId = currentPet?.petId;

    ref.listen<PetInfo?>(currentPetProvider, (previous, next) {
      final nextPetId = next?.petId;
      if (nextPetId != null && nextPetId != state.petId) {
        state = state.copyWith(petId: nextPetId);
        _fetch();
      } else if (nextPetId == null && state.petId != 0) {
        // pet이 없어지면 초기화 (에러 상태로 설정)
        state = state.copyWith(
          petId: 0,
          monthlyData: const AsyncValue.loading(),
        );
      }
    });

    // petId가 있을 때만 fetch
    if (petId != null && petId > 0) {
      Future.microtask(_fetch);
    }
    
    return CalendarState.initial(
      petId: petId ?? 0,
      date: now,
    );
  }

  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    // petId가 없거나 0이면 API 호출하지 않음
    if (state.petId == null || state.petId == 0) {
      return;
    }

    // 임시: petId가 1이면 currentPetProvider를 다시 확인
    if (state.petId == 1) {
      final currentPet = ref.read(currentPetProvider);
      if (currentPet == null || currentPet.petId != 1) {
        state = state.copyWith(
          petId: currentPet?.petId ?? 0,
          monthlyData: const AsyncValue.loading(),
        );
        if (state.petId == 0) return;
      }
    }

    state = state.copyWith(monthlyData: const AsyncValue.loading());
    try {
      final response = await _service.getMonthlyEvents(
        petId: state.petId,
        year: state.year,
        month: state.month,
      );
      state = state.copyWith(monthlyData: AsyncValue.data(response));
    } catch (error, stackTrace) {
      state = state.copyWith(
        monthlyData: AsyncValue.error(error, stackTrace),
      );
    }
  }

  void changeMonth(DateTime date) {
    if (state.year == date.year && state.month == date.month) return;
    if (state.petId == 0 || state.petId == null) return; // petId가 없으면 변경하지 않음
    state = state.copyWith(
      year: date.year,
      month: date.month,
    );
    _fetch();
  }

  void updatePet(int petId) {
    if (petId == state.petId) return;
    if (petId == 0) return; // petId가 0이면 업데이트하지 않음
    state = state.copyWith(petId: petId);
    _fetch();
  }
}

