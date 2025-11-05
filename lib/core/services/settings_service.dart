// lib/core/services/settings_service.dart
// 환경 설정 저장/로드 래퍼(SharedPreferences)
// - 앱 시작 시 initialize()로 인스턴스 준비
// - 테마 모드(system/light/dark) 저장·로드
// - 알림 on/off, 일일 알림 시각(hour/minute) 저장·로드
// - 주간/월간 알림 사용 여부 저장·로드
// - 설정값 초기화(clearSettings) 제공

import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static SharedPreferences? _prefs;

  // 기본값
  static const _defaultTheme = 'system';
  static const _defaultNotiEnabled = true;
  static const _defaultNotiHour = 9;
  static const _defaultNotiMinute = 0;
  static const _defaultWeekly = false;
  static const _defaultMonthly = false;

  // 키
  static const _kTheme = 'theme_mode';
  static const _kNotifEnabled = 'notif_enabled';
  static const _kNotifHour = 'notif_hour';
  static const _kNotifMinute = 'notif_minute';
  static const _kWeekly = 'notif_weekly';
  static const _kMonthly = 'notif_monthly';

  // 초기화
  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // 테마
  static Future<bool> setThemeMode(String mode) async {
    assert(mode == 'system' || mode == 'light' || mode == 'dark');
    return _prefs!.setString(_kTheme, mode);
  }

  static String getThemeMode() {
    return _prefs?.getString(_kTheme) ?? _defaultTheme;
  }

  // 알림 on/off
  static Future<bool> setNotificationEnabled(bool value) async {
    return _prefs!.setBool(_kNotifEnabled, value);
  }

  static bool getNotificationEnabled() {
    return _prefs?.getBool(_kNotifEnabled) ?? _defaultNotiEnabled;
  }

  // 일일 알림 시각
  static Future<bool> setNotificationTime(int hour, int minute) async {
    final ok1 = await _prefs!.setInt(_kNotifHour, hour);
    final ok2 = await _prefs!.setInt(_kNotifMinute, minute);
    return ok1 && ok2;
  }

  static ({int hour, int minute}) getNotificationTime() {
    final h = _prefs?.getInt(_kNotifHour) ?? _defaultNotiHour;
    final m = _prefs?.getInt(_kNotifMinute) ?? _defaultNotiMinute;
    return (hour: h, minute: m);
  }

  // 주간/월간 알림 사용 여부
  static Future<bool> setWeeklyEnabled(bool value) async {
    return _prefs!.setBool(_kWeekly, value);
  }

  static bool getWeeklyEnabled() {
    return _prefs?.getBool(_kWeekly) ?? _defaultWeekly;
  }

  static Future<bool> setMonthlyEnabled(bool value) async {
    return _prefs!.setBool(_kMonthly, value);
  }

  static bool getMonthlyEnabled() {
    return _prefs?.getBool(_kMonthly) ?? _defaultMonthly;
  }

  // 설정 초기화
  static Future<void> clearSettings() async {
    await _prefs?.remove(_kTheme);
    await _prefs?.remove(_kNotifEnabled);
    await _prefs?.remove(_kNotifHour);
    await _prefs?.remove(_kNotifMinute);
    await _prefs?.remove(_kWeekly);
    await _prefs?.remove(_kMonthly);
  }
}
