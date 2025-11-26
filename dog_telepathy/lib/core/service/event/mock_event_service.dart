import 'dart:io';
import '../../models/event_info.dart';
import '../../exceptions.dart';
import 'event_service.dart';

class MockEventService implements EventService {
  @override
  Future<List<EventInfo>> getPetEvents({
    required int petId,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      return _getMockEvents(petId, skip, limit);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException("Mock 이벤트 불러오기 실패", e);
    }
  }

  List<EventInfo> _getMockEvents(int petId, int skip, int limit) {
    final now = DateTime.now();
    final list = <EventInfo>[];

    for (int i = 0; i < limit && i < 20; i++) {
      final startTime = now.subtract(Duration(hours: i));
      final duration = 30 + (i % 60);
      final endTime = startTime.add(Duration(seconds: duration));

      final emotions = ['행복', '평온', '활발', '불안', '화남'];
      final emotion = emotions[i % emotions.length];
      final isCompleted = i % 3 != 0;

      list.add(
        EventInfo(
          eventId: 1000 + i,
          petId: petId,
          deviceId: 1,
          startTime: startTime,
          endTime: endTime,
          videoDurationSec: duration,
          videoUrl: 'https://mock.server/videos/mock$i.mp4',
          thumbnailUrl: 'https://mock.server/thumbnails/mock$i.jpg',
          analysisStatus: isCompleted ? AnalysisStatus.completed : AnalysisStatus.pending,
          detectedFeatures: isCompleted ? "Mock 행동 분석" : null,
          finalEmotion: isCompleted ? emotion : null,
        ),
      );
    }

    return list.skip(skip).take(limit).toList();
  }
}
