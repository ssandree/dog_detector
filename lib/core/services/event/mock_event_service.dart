import 'dart:io';
import '../../../models/event_info.dart';
import '../../exceptions.dart';
import 'event_service.dart';

/// Mock 이벤트 서비스 구현체
/// API 없이도 동작하는 가짜 구현체
class MockEventService implements EventService {
  @override
  Future<EventInfo> uploadEvent({
    required File file,
    required int petId,
    required int deviceId,
    required DateTime startTime,
    required int videoDurationSec,
  }) async {
    try {
      // TODO: 실제 API 호출로 변경
      // final formData = FormData.fromMap({
      //   'file': await MultipartFile.fromFile(file.path),
      //   'pet_id': petId,
      //   'device_id': deviceId,
      //   'start_time': startTime.toIso8601String(),
      //   'video_duration_sec': videoDurationSec,
      // });
      // final response = await dio.post('/events/upload', data: formData);
      // return EventInfo.fromJson(response.data);

      await Future.delayed(const Duration(milliseconds: 1000)); // 업로드 시뮬레이션

      // Mock 응답
      final endTime = startTime.add(Duration(seconds: videoDurationSec));
      return EventInfo(
        eventId: DateTime.now().millisecondsSinceEpoch,
        petId: petId,
        deviceId: deviceId,
        startTime: startTime,
        endTime: endTime,
        videoDurationSec: videoDurationSec,
        videoUrl: 'https://bucket.s3.region.amazonaws.com/videos/user_1/uuid.mp4',
        thumbnailUrl: 'https://bucket.s3.region.amazonaws.com/videos/user_1/uuid_thumb.jpg',
        analysisStatus: AnalysisStatus.pending,
        detectedFeatures: null,
        finalEmotion: null,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '영상 업로드에 실패했습니다',
        e,
      );
    }
  }

  @override
  Future<List<EventInfo>> getPetEvents({
    required int petId,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      // TODO: 실제 API 호출로 변경
      // final response = await dio.get(
      //   '/pets/$petId/events',
      //   queryParameters: {'skip': skip, 'limit': limit},
      // );
      // final List<dynamic> data = response.data;
      // return data.map((json) => EventInfo.fromJson(json)).toList();

      await Future.delayed(const Duration(milliseconds: 500));

      // Mock 데이터 반환
      return _getMockEvents(petId, skip, limit);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '이벤트 목록을 불러오는데 실패했습니다',
        e,
      );
    }
  }

  /// Mock 이벤트 데이터 생성
  List<EventInfo> _getMockEvents(int petId, int skip, int limit) {
    final now = DateTime.now();
    final events = <EventInfo>[];

    for (int i = 0; i < limit && i < 20; i++) {
      final startTime = now.subtract(Duration(hours: i));
      final duration = 30 + (i % 60); // 30~90초
      final endTime = startTime.add(Duration(seconds: duration));
      
      final emotions = ['행복', '평온', '활발', '불안', '화남'];
      final emotion = emotions[i % emotions.length];
      final isCompleted = i % 3 != 0; // 일부는 완료 상태

      events.add(EventInfo(
        eventId: 1000 + i,
        petId: petId,
        deviceId: 1,
        startTime: startTime,
        endTime: endTime,
        videoDurationSec: duration,
        videoUrl: 'https://bucket.s3.region.amazonaws.com/videos/user_1/uuid$i.mp4',
        thumbnailUrl: 'https://bucket.s3.region.amazonaws.com/videos/user_1/uuid${i}_thumb.jpg',
        analysisStatus: isCompleted ? AnalysisStatus.completed : AnalysisStatus.pending,
        detectedFeatures: isCompleted ? '행동 특징 분석 결과...' : null,
        finalEmotion: isCompleted ? emotion : null,
      ));
    }

    return events.skip(skip).take(limit).toList();
  }
}

