// lib/core/providers/settings_provider.dart
// 앱 환경 설정 상태 관리
// - 비동기 초기화(SharedPreferences, Hive, NotificationService 등)
// - AsyncValue 기반 상태 : loading/data/error 자동 관리

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';
import '../utils/theme_util.dart';
import '../config/app_routes.dart';
import '../../local/hive_cache_util.dart';

// 불변 상태 클래스
class SettingsState {
  final ThemeMode themeMode;
  final bool notificationEnabled;
  final ({int hour, int minute}) notificationTime;
  final bool weeklyEnabled;
  final bool monthlyEnabled;

  const SettingsState({
    required this.themeMode,
    required this.notificationEnabled,
    required this.notificationTime,
    required this.weeklyEnabled,
    required this.monthlyEnabled,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? notificationEnabled,
    ({int hour, int minute})? notificationTime,
    bool? weeklyEnabled,
    bool? monthlyEnabled,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      weeklyEnabled: weeklyEnabled ?? this.weeklyEnabled,
      monthlyEnabled: monthlyEnabled ?? this.monthlyEnabled,
    );
  }
}

// AsyncNotifier 구현체
class SettingsNotifier extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() async {
    await SettingsService.initialize();
    return SettingsState(
      themeMode: ThemeUtil.getCurrentTheme(),
      notificationEnabled: SettingsService.getNotificationEnabled(),
      notificationTime: SettingsService.getNotificationTime(),
      weeklyEnabled: SettingsService.getWeeklyEnabled(),
      monthlyEnabled: SettingsService.getMonthlyEnabled(),
    );
  }

  Future<void> setTheme(String mode) async {
    await ThemeUtil.setTheme(mode);
    final newTheme = ThemeUtil.getCurrentTheme();
    state = AsyncValue.data(state.value!.copyWith(themeMode: newTheme));
  }

  Future<void> toggleNotification(bool enabled) async {
    await SettingsService.setNotificationEnabled(enabled);
    if (!enabled) await NotificationService().cancelAll();
    state = AsyncValue.data(state.value!.copyWith(notificationEnabled: enabled));
  }

  Future<void> setNotificationTime(int hour, int minute) async {
    await SettingsService.setNotificationTime(hour, minute);
    final now = DateTime.now();
    final scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    await NotificationService().scheduleNotification(
      id: 0,
      title: '감정 리포트 알림',
      body: '오늘의 감정 리포트를 확인하세요.',
      scheduledTime: scheduled,
      payload: AppRoutes.deepLinkReportHome,
    );
    state = AsyncValue.data(
      state.value!.copyWith(notificationTime: (hour: hour, minute: minute)),
    );
  }

  Future<void> setWeekly(bool enabled) async {
    await SettingsService.setWeeklyEnabled(enabled);
    state = AsyncValue.data(state.value!.copyWith(weeklyEnabled: enabled));
  }

  Future<void> setMonthly(bool enabled) async {
    await SettingsService.setMonthlyEnabled(enabled);
    state = AsyncValue.data(state.value!.copyWith(monthlyEnabled: enabled));
  }

  Future<void> clearCache() async {
    await HiveCacheUtil.clearAll();
  }

  Future<void> resetAll() async {
    await SettingsService.clearSettings();
    final fresh = await build();
    state = AsyncValue.data(fresh);
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
