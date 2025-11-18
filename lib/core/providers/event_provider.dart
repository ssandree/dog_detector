import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../models/event_info.dart';
import '../services/event/event_service.dart';
import '../services/event/mock_event_service.dart';

/// EventService Provider
final eventServiceProvider = Provider<EventService>((ref) {
  return MockEventService();
});

/// 반려동물별 이벤트 목록 상태를 관리하는 Provider
final petEventsProvider = FutureProvider.family<List<EventInfo>, ({int petId, int skip, int limit})>(
  (ref, params) async {
    final eventService = ref.watch(eventServiceProvider);
    return await eventService.getPetEvents(
      petId: params.petId,
      skip: params.skip,
      limit: params.limit,
    );
  },
);

