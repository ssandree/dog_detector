// lib/screens/settings/settings_home_screen.dart
// 환경 설정 메인 화면
// - flutter_settings_screens 최신 구조 반영
// - SettingsProvider 연동
// - 알림, 캐시, 테마, 앱 정보 표시

import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dog_telepathy/core/providers/settings_provider.dart';
import '../../core/config/app_routes.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class SettingsHomeScreen extends HookConsumerWidget {
  const SettingsHomeScreen({super.key});

  Future<Map<String, String>> _loadAppInfo() async {
    final jsonStr = await rootBundle.loadString('assets/app_info.json');
    final data = json.decode(jsonStr);
    return {
      'version': data['version'] ?? 'unknown',
      'build': data['build'] ?? 'unknown',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSettings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return asyncSettings.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('설정 로드 실패: $e')),
      ),
      data: (settings) => FutureBuilder(
        future: _loadAppInfo(),
        builder: (context, snapshot) {
          final version = snapshot.data?['version'] ?? '';
          final build = snapshot.data?['build'] ?? '';

          return Scaffold(
            appBar: AppBar(title: const Text('환경 설정')),
            body: SafeArea(
              child: SettingsScreen(
                title: '설정',
                children: [
                  SettingsGroup(
                    title: '테마',
                    children: [
                      DropDownSettingsTile<String>(
                        title: '테마 모드',
                        settingKey: 'theme_mode',
                        selected: _themeString(settings.themeMode),
                        values: const {
                          'system': '시스템 기본',
                          'light': '라이트 모드',
                          'dark': '다크 모드',
                        },
                        onChange: (value) async {
                          await notifier.setTheme(value);
                        },
                      ),
                    ],
                  ),
                  SettingsGroup(
                    title: '알림',
                    children: [
                      SwitchSettingsTile(
                        settingKey: 'notifications_enabled',
                        title: '알림 활성화',
                        leading: const Icon(Icons.notifications_active),
                        defaultValue: settings.notificationEnabled,
                        onChange: (val) => notifier.toggleNotification(val),
                      ),
                      SimpleSettingsTile(
                        title: '알림 세부 설정',
                        leading: const Icon(Icons.alarm),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.notificationSettings,
                        ),
                      ),
                    ],
                  ),
                  SettingsGroup(
                    title: '저장 공간',
                    children: [
                      SimpleSettingsTile(
                        title: '로컬 캐시 초기화',
                        leading: const Icon(Icons.delete_forever),
                        onTap: () async {
                          await notifier.clearCache();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('캐시가 초기화되었습니다.'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  SettingsGroup(
                    title: '앱 정보',
                    children: [
                      SimpleSettingsTile(
                        title: '버전 $version (build $build)',
                        leading: const Icon(Icons.info_outline),
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _themeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}
