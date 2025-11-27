import 'dart:math';

import '../../exceptions.dart';

/// 한 달치 감정/이벤트 집계를 담는 DTO
class MonthlyCalendarResponse {
  final int petId;
  final int year;
  final int month;
  final Map<int, MonthlyDayStat> days; // key = day(1~31)

  const MonthlyCalendarResponse({
    required this.petId,
    required this.year,
    required this.month,
    required this.days,
  });

  Map<String, double> toHeatmapRatios() {
    final ratios = <String, double>{};
    final monthKey = month.toString().padLeft(2, '0');

    days.forEach((day, stat) {
      final dayKey = '$monthKey-${day.toString().padLeft(2, '0')}';
      ratios[dayKey] = stat.totalEvents == 0 ? -1.0 : stat.negativeRatio;
    });

    return ratios;
  }
}

/// 단일 날짜의 감정/이벤트 통계
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

  double get negativeRatio =>
      totalEvents == 0 ? 0 : (angry + fear) / totalEvents;
}

/// API 명세를 흉내 내는 Mock Service
class MockCalendarService {
  final Random _random = Random();

  Future<MonthlyCalendarResponse> getMonthlyEvents({
    required int petId,
    required int year,
    required int month,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 350));
      final daysInMonth = _daysInMonth(year, month);
      final days = <int, MonthlyDayStat>{};

      for (int day = 1; day <= daysInMonth; day++) {
        days[day] = _generateDayStat(day);
      }

      return MonthlyCalendarResponse(
        petId: petId,
        year: year,
        month: month,
        days: days,
      );
    } catch (e) {
      throw NetworkException('Mock 월간 이벤트 생성 실패', e);
    }
  }

  MonthlyDayStat _generateDayStat(int day) {
    final bool shouldSkip = _random.nextDouble() < 0.15;
    if (shouldSkip) {
      return const MonthlyDayStat(
        happy: 0,
        calm: 0,
        angry: 0,
        fear: 0,
        totalEvents: 0,
        score: 0,
      );
    }

    final happy = _random.nextInt(5);
    final calm = _random.nextInt(3);
    final angry = _random.nextInt(3);
    final fear = _random.nextInt(2);
    final total = happy + calm + angry + fear;
    final score = (happy + calm) - (angry + fear);

    return MonthlyDayStat(
      happy: happy,
      calm: calm,
      angry: angry,
      fear: fear,
      totalEvents: total,
      score: score,
    );
  }

  int _daysInMonth(int year, int month) {
    final beginningNextMonth =
        (month == 12) ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    return beginningNextMonth.subtract(const Duration(days: 1)).day;
  }
}

