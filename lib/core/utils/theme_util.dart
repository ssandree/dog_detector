// lib/core/utils/theme_util.dart
// 앱 전역 테마 유틸리티
// - 라이트/다크/시스템 테마 관리
// - SharedPreferences 기반 모드 유지(SettingsService 연동)
// - ThemeMode 변환 전용 헬퍼

import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class ThemeUtil {
  static ThemeMode getCurrentTheme() {
    final mode = SettingsService.getThemeMode();
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static Future<void> setTheme(String mode) async {
    await SettingsService.setThemeMode(mode);
  }
}
