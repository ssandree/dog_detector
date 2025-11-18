import 'dart:io';
import '../../../models/event_info.dart';
import 'event_service.dart';

/// Remote 이벤트 서비스 구현체
/// 실제 API 호출하는 구현체
class RemoteEventService implements EventService {
  @override
  Future<EventInfo> uploadEvent({
    required File file,
    required int petId,
    required int deviceId,
    required DateTime startTime,
    required int videoDurationSec,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<EventInfo>> getPetEvents({
    required int petId,
    int skip = 0,
    int limit = 100,
  }) {
    throw UnimplementedError();
  }
}

