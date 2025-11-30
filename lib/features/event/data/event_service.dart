// lib/features/home/service/event/event_service.dart

import '../domain/event_info.dart';

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
