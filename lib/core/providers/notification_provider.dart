// lib/core/providers/notification_provider.dart
// 알림 설정 상태 관리 Provider
// - shared_preferences 기반 데이터 영속화
// - 알림 on/off, 시간대, 주기(일/주/월) 관리
// - NotificationService와 TimeUtil을 통해 예약 반영

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/time_util.dart';

final notificationProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(
        NotificationNotifier.new);

class NotificationState {
  final bool enabled;
  final TimeOfDay dailyTime;
  final bool weeklyEnabled;
  final bool monthlyEnabled;

  const NotificationState({
    required this.enabled,
    required this.dailyTime,
    required this.weeklyEnabled,
    required this.monthlyEnabled,
  });

  NotificationState copyWith({
    bool? enabled,
    TimeOfDay? dailyTime,
    bool? weeklyEnabled,
    bool? monthlyEnabled,
  }) {
    return NotificationState(
      enabled: enabled ?? this.enabled,
      dailyTime: dailyTime ?? this.dailyTime,
      weeklyEnabled: weeklyEnabled ?? this.weeklyEnabled,
      monthlyEnabled: monthlyEnabled ?? this.monthlyEnabled,
    );
  }
}

class NotificationNotifier extends Notifier<NotificationState> {
  late SharedPreferences _prefs;

  @override
  NotificationState build() {
    _init();
    return const NotificationState(
      enabled: true,
      dailyTime: TimeOfDay(hour: 9, minute: 0),
      weeklyEnabled: false,
      monthlyEnabled: false,
    );
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();

    final enabled = _prefs.getBool('notif_enabled') ?? true;
    final hour = _prefs.getInt('notif_hour') ?? 9;
    final minute = _prefs.getInt('notif_minute') ?? 0;
    final weekly = _prefs.getBool('notif_weekly') ?? false;
    final monthly = _prefs.getBool('notif_monthly') ?? false;

    state = NotificationState(
      enabled: enabled,
      dailyTime: TimeOfDay(hour: hour, minute: minute),
      weeklyEnabled: weekly,
      monthlyEnabled: monthly,
    );
  }

  Future<void> toggle(bool value) async {
    state = state.copyWith(enabled: value);
    await _prefs.setBool('notif_enabled', value);

    if (!value) {
      await NotificationService().cancelAll();
    }
  }

  Future<void> setDailyTime(TimeOfDay time) async {
    state = state.copyWith(dailyTime: time);
    await _prefs.setInt('notif_hour', time.hour);
    await _prefs.setInt('notif_minute', time.minute);

    if (state.enabled) {
      final next = TimeUtil.nextOccurrence(time);
      await NotificationService().scheduleNotification(
        id: 1,
        title: '일일 리포트 알림',
        body: '오늘의 감정 분석 리포트가 준비되었습니다.',
        scheduledTime: next,
        payload: 'report_home',
      );
    }
  }

  Future<void> setWeekly(bool value) async {
    state = state.copyWith(weeklyEnabled: value);
    await _prefs.setBool('notif_weekly', value);
  }

  Future<void> setMonthly(bool value) async {
    state = state.copyWith(monthlyEnabled: value);
    await _prefs.setBool('notif_monthly', value);
  }
}
