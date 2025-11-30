// lib/manager/logic/service/event_service.dart

import '../model/event_info.dart';

abstract class EventService {
  Future<List<EventInfo>> getPetEvents({
    required int petId,
    int skip = 0,
    int limit = 100,
  });

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
          MonthlyEventStat.fromJson(Map<String, dynamic>.from(entry.value));
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

  Map<String, dynamic> toJson() => {
        'happy': happy,
        'calm': calm,
        'angry': angry,
        'fear': fear,
        'total_events': totalEvents,
        'score': score,
      };
}

/// 캘린더 UI를 위한 월간 응답 모델
class MonthlyCalendarResponse {
  final int petId;
  final int year;
  final int month;
  final Map<int, MonthlyDayStat> days;

  const MonthlyCalendarResponse({
    required this.petId,
    required this.year,
    required this.month,
    required this.days,
  });

  /// 히트맵 비율 맵으로 변환
  /// 반환값: 'MM-dd' 형식의 키와 0.0~1.0 사이의 비율 값
  Map<String, double> toHeatmapRatios() {
    final ratios = <String, double>{};
    
    for (final entry in days.entries) {
      final day = entry.key;
      final stat = entry.value;
      
      // 날짜 키 생성 (MM-dd 형식)
      final dateKey = '${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      
      // 총 이벤트가 0이면 -1.0 (데이터 없음)
      if (stat.totalEvents == 0) {
        ratios[dateKey] = -1.0;
      } else {
        // 부정 감정 비율 계산: (angry + fear) / totalEvents
        final negativeRatio = (stat.angry + stat.fear) / stat.totalEvents;
        ratios[dateKey] = negativeRatio.clamp(0.0, 1.0);
      }
    }
    
    return ratios;
  }
}

/// 캘린더 UI를 위한 일일 통계 모델
class MonthlyDayStat {
  final int happy;
  final int calm;
  final int angry;
  final int fear;
  final int totalEvents;
  final int score;

  const MonthlyDayStat({
    required this.happy,
    required this.calm,
    required this.angry,
    required this.fear,
    required this.totalEvents,
    required this.score,
  });
}
