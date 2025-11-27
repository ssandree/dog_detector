import 'dart:io';
import '../../models/event_info.dart';

/// 이벤트 관련 비즈니스 로직을 처리하는 Service 인터페이스
abstract class EventService {
  // /// 영상 업로드 및 이벤트 생성
  // /// 
  // /// [file]: 업로드할 영상 파일
  // /// [petId]: 반려동물 ID
  // /// [deviceId]: 디바이스 ID
  // /// [startTime]: 영상 시작 시간
  // /// [videoDurationSec]: 영상 길이 (초)
  // /// 반환값: 생성된 EventInfo 객체
  // /// 예외: NetworkException, ValidationException
  // Future<EventInfo> uploadEvent({
  //   required File file,
  //   required int petId,
  //   required int deviceId,
  //   required DateTime startTime,
  //   required int videoDurationSec,
  // });

  /// 반려동물별 이벤트 목록 조회
  /// 
  /// [petId]: 반려동물 ID
  /// [skip]: 건너뛸 레코드 수 (페이지네이션)
  /// [limit]: 반환할 최대 레코드 수
  /// 반환값: EventInfo 리스트
  /// 예외: NetworkException, DataException
  Future<List<EventInfo>> getPetEvents({
    required int petId,
    int skip = 0,
    int limit = 100,
  });

  /// 하루 단위 이벤트 목록 조회
  ///
  /// [petId]: 반려동물 ID
  /// [date]: 조회할 날짜 (로컬 타임존 기준)
  /// 반환값: DailyPetEvents (선택한 날짜의 이벤트 묶음)
  /// 예외: NetworkException, DataException
  Future<DailyPetEvents> getDailyPetEvents({
    required int petId,
    required DateTime date,
  });

  Future<MonthlyEventsSummary> getMonthlyEvents({
    required int petId,
    required int year,
    required int month,
  });
}

class MonthlyEventsSummary {
  final int petId;
  final int year;
  final int month;
  final Map<int, MonthlyEventStat> days;

  const MonthlyEventsSummary({
    required this.petId,
    required this.year,
    required this.month,
    required this.days,
  });

  factory MonthlyEventsSummary.fromJson(Map<String, dynamic> json) {
    final daysJson = json['days'] as Map<String, dynamic>? ?? {};
    final parsedDays = <int, MonthlyEventStat>{};

    for (final entry in daysJson.entries) {
      final day = int.tryParse(entry.key);
      if (day == null) continue;
      parsedDays[day] =
          MonthlyEventStat.fromJson(entry.value as Map<String, dynamic>);
    }

    return MonthlyEventsSummary(
      petId: json['pet_id'] as int,
      year: json['year'] as int,
      month: json['month'] as int,
      days: parsedDays,
    );
  }
}

class MonthlyEventStat {
  final int happy;
  final int calm;
  final int angry;
  final int fear;
  final int totalEvents;
  final int score;

  const MonthlyEventStat({
    required this.happy,
    required this.calm,
    required this.angry,
    required this.fear,
    required this.totalEvents,
    required this.score,
  });

  factory MonthlyEventStat.fromJson(Map<String, dynamic> json) {
    return MonthlyEventStat(
      happy: json['happy'] as int? ?? 0,
      calm: json['calm'] as int? ?? 0,
      angry: json['angry'] as int? ?? 0,
      fear: json['fear'] as int? ?? 0,
      totalEvents: json['total_events'] as int? ?? 0,
      score: json['score'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'happy': happy,
      'calm': calm,
      'angry': angry,
      'fear': fear,
      'total_events': totalEvents,
      'score': score,
    };
  }
}

