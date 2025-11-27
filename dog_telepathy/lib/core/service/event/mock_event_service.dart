import 'dart:io';
import '../../data/event_mock.dart';
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

      final events = _getStaticEventsForPet(petId);
      if (events.length >= skip + limit) {
        return events.skip(skip).take(limit).toList();
      }

      final needed = (skip + limit) - events.length;
      final fallback = _generateFallbackEvents(
        petId: petId,
        count: needed + 5,
        anchor: DateTime.now(),
      );

      return [...events, ...fallback]
          .skip(skip)
          .take(limit)
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException("Mock 이벤트 불러오기 실패", e);
    }
  }

  @override
  Future<DailyPetEvents> getDailyPetEvents({
    required int petId,
    required DateTime date,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final normalized = DateTime(date.year, date.month, date.day);
      final events = _loadDailyFromMock(petId, normalized);

      return DailyPetEvents(
        petId: petId,
        date: normalized,
        events: events,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException("Mock 하루 단위 이벤트 불러오기 실패", e);
    }
  }

  @override
  Future<MonthlyEventsSummary> getMonthlyEvents({
    required int petId,
    required int year,
    required int month,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 250));
      final summaryFromMock = _loadMonthlySummaryFromMock(
        petId: petId,
        year: year,
        month: month,
      );

      if (summaryFromMock != null) {
        return summaryFromMock;
      }

      return _generateMonthlySummary(
        petId: petId,
        year: year,
        month: month,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException("Mock 월간 이벤트 불러오기 실패", e);
    }
  }

  List<EventInfo> _getStaticEventsForPet(int petId) {
    return mockEventList
        .where((json) => json['pet_id'] == petId)
        .map(_eventFromJson)
        .toList();
  }

  List<EventInfo> _generateFallbackEvents({
    required int petId,
    required int count,
    required DateTime anchor,
  }) {
    final list = <EventInfo>[];
    final emotions = ['행복', '평온', '활발', '불안', '화남'];

    for (int i = 0; i < count; i++) {
      final startTime = anchor.subtract(Duration(hours: i * 2));
      final duration = 30 + (i % 30);
      final endTime = startTime.add(Duration(seconds: duration));
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
          videoUrl: 'https://mock.server/videos/fallback_$i.mp4',
          thumbnailUrl: 'https://mock.server/thumbnails/fallback_$i.jpg',
          analysisStatus:
              isCompleted ? AnalysisStatus.completed : AnalysisStatus.pending,
          detectedFeatures:
              isCompleted ? '자동 생성 행동 분석' : '분석 중입니다',
          finalEmotion: isCompleted ? emotion : null,
        ),
      );
    }

    return list;
  }

  List<EventInfo> _generateDailyEvents({
    required int petId,
    required DateTime date,
    required int count,
  }) {
    final list = <EventInfo>[];
    final base = DateTime(date.year, date.month, date.day, 7);
    final emotions = ['행복', '평온', '활발', '불안', '경계'];

    for (int i = 0; i < count; i++) {
      final startTime = base.add(Duration(hours: i * 2));
      final duration = 40 + (i % 20);
      final endTime = startTime.add(Duration(seconds: duration));
      final emotion = emotions[i % emotions.length];

      list.add(
        EventInfo(
          eventId: 2000 + i,
          petId: petId,
          deviceId: 1,
          startTime: startTime,
          endTime: endTime,
          videoDurationSec: duration,
          videoUrl: 'https://mock.server/videos/daily_${date.toIso8601String()}_$i.mp4',
          thumbnailUrl: 'https://mock.server/thumbnails/daily_${date.toIso8601String()}_$i.jpg',
          analysisStatus: AnalysisStatus.completed,
          detectedFeatures: '자동 생성 일별 이벤트',
          finalEmotion: emotion,
        ),
      );
    }

    return list;
  }

  EventInfo _eventFromJson(Map<String, dynamic> json) {
    final startRaw = json['start_time'] as String?;
    final endRaw = json['end_time'] as String?;
    final start = startRaw != null ? DateTime.parse(startRaw).toLocal() : DateTime.now();
    final end = endRaw != null ? DateTime.parse(endRaw).toLocal() : start.add(const Duration(seconds: 30));
    final finalEmotion = json['final_emotion'] as String?;
    final duration = json['video_duration_sec'] as int? ?? end.difference(start).inSeconds;

    return EventInfo(
      eventId: json['event_id'] as int,
      petId: json['pet_id'] as int,
      deviceId: json['device_id'] as int? ?? 0,
      startTime: start,
      endTime: end,
      videoDurationSec: duration,
      videoUrl: json['video_url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      analysisStatus:
          finalEmotion != null ? AnalysisStatus.completed : AnalysisStatus.pending,
      detectedFeatures: json['detected_features'] as String?,
      finalEmotion: finalEmotion,
      patellaAnalysisResult: json['patella_analysis_result'] as String?,
    );
  }

  List<EventInfo> _loadDailyFromMock(int petId, DateTime normalized) {
    final mockResponse = getMockDailyEventResponse();
    final pet = mockResponse['pet_id'] as int?;
    final dateStr = mockResponse['date'] as String?;
    
    // petId가 일치하는지 확인
    if (pet != petId) {
      return [];
    }
    
    // 날짜 문자열이 있는지 확인
    if (dateStr == null) {
      return [];
    }
    
    // 날짜 문자열을 파싱 (YYYY-MM-DD 형식)
    final dateParts = dateStr.split('-');
    if (dateParts.length != 3) {
      return [];
    }
    
    final mockYear = int.tryParse(dateParts[0]);
    final mockMonth = int.tryParse(dateParts[1]);
    final mockDay = int.tryParse(dateParts[2]);
    
    if (mockYear == null || mockMonth == null || mockDay == null) {
      return [];
    }
    
    // 날짜가 일치하는지 확인 (연/월/일 직접 비교)
    if (mockYear == normalized.year &&
        mockMonth == normalized.month &&
        mockDay == normalized.day) {
      final eventsJson =
          (mockResponse['events'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>();
      return eventsJson.map(_eventFromJson).toList();
    }
    
    return [];
  }

  MonthlyEventsSummary? _loadMonthlySummaryFromMock({
    required int petId,
    required int year,
    required int month,
  }) {
    final mockPetId = mockMonthlyEventResponse['pet_id'] as int?;
    final mockYear = mockMonthlyEventResponse['year'] as int?;
    final mockMonth = mockMonthlyEventResponse['month'] as int?;

    if (mockPetId == petId &&
        mockYear == year &&
        mockMonth == month) {
      return MonthlyEventsSummary.fromJson(mockMonthlyEventResponse);
    }
    return null;
  }

  MonthlyEventsSummary _generateMonthlySummary({
    required int petId,
    required int year,
    required int month,
  }) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final seedBase = DateTime(year, month, 1).microsecondsSinceEpoch + petId;
    final days = <int, MonthlyEventStat>{};

    for (int day = 1; day <= daysInMonth; day++) {
      final seed = seedBase + day * 17;
      final happy = (seed % 4);
      final calm = (seed ~/ 3) % 3;
      final angry = (seed ~/ 5) % 2;
      final fear = (seed ~/ 7) % 2;
      final total = happy + calm + angry + fear;
      final score = (happy + calm) - (angry + fear);

      days[day] = MonthlyEventStat(
        happy: happy,
        calm: calm,
        angry: angry,
        fear: fear,
        totalEvents: total,
        score: score,
      );
    }

    return MonthlyEventsSummary(
      petId: petId,
      year: year,
      month: month,
      days: days,
    );
  }
}
