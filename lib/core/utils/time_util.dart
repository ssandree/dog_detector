// lib/utils/time_util.dart
// 시간 관련 유틸리티 모음
// - DateTime ↔ TZDateTime 변환
// - 알림 예약 시간 계산
// - 시간 문자열 포맷 처리

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class TimeUtil {
  // 로컬 시간대 반환
  static tz.Location get local => tz.local;

  // DateTime → TZDateTime 변환
  static tz.TZDateTime toTZ(DateTime date) {
    return tz.TZDateTime.from(date, tz.local);
  }

  // TZDateTime → DateTime 변환
  static DateTime fromTZ(tz.TZDateTime tzTime) {
    return tzTime.toLocal();
  }

  // 다음 특정 시각 반환
  static DateTime nextOccurrence(TimeOfDay time) {
    final now = DateTime.now();
    var scheduled =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // 시간 포맷
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  // 요일 표시
  static String weekdayLabel(DateTime time) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[time.weekday - 1];
  }
}
