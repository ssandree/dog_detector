// lib/screens/settings/notification_settings_screen.dart
// 알림 설정 화면
// - 일/주/월 단위 알림 활성화 및 시각 지정
// - SettingsProvider와 연동(notificationProvider 통합 버전)
// - SharedPreferences 기반 데이터 영속화 및 NotificationService 동기화

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dog_telepathy/core/providers/settings_provider.dart';
import '../../core/utils/time_util.dart';

class NotificationSettingsScreen extends HookConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSettings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    // 비동기 상태 핸들링
    return asyncSettings.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('설정 로드 실패: $e')),
      ),
      data: (settings) => Scaffold(
        appBar: AppBar(title: const Text('알림 설정')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: const Text('알림 활성화'),
              value: settings.notificationEnabled,
              onChanged: (v) => notifier.toggleNotification(v),
            ),
            const Divider(height: 24),
            ListTile(
              title: const Text('일일 리포트 알림 시각'),
              subtitle: Text(
                TimeUtil.formatTime(
                  DateTime(0, 0, 0, settings.notificationTime.hour,
                      settings.notificationTime.minute),
                ),
              ),
              trailing: const Icon(Icons.access_time),
              enabled: settings.notificationEnabled,
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: settings.notificationTime.hour,
                    minute: settings.notificationTime.minute,
                  ),
                );
                if (picked != null) {
                  await notifier.setNotificationTime(
                      picked.hour, picked.minute);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '일일 알림이 ${picked.hour}시 ${picked.minute}분으로 설정되었습니다.',
                      ),
                    ),
                  );
                }
              },
            ),
            const Divider(height: 24),
            SwitchListTile(
              title: const Text('주간 리포트 알림'),
              value: settings.weeklyEnabled,
              onChanged:
                  settings.notificationEnabled ? notifier.setWeekly : null,
            ),
            SwitchListTile(
              title: const Text('월간 리포트 알림'),
              value: settings.monthlyEnabled,
              onChanged:
                  settings.notificationEnabled ? notifier.setMonthly : null,
            ),
          ],
        ),
      ),
    );
  }
}
