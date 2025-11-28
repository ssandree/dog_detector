import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/app_constants.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/models/notification_models.dart';
import '../../../../core/widgets/onoff_button.dart';
import 'setting_row.dart';

class NotificationSettingsSection extends StatelessWidget {
  final AsyncValue<NotificationSettings> settings;
  final Future<void> Function(bool value) onToggleInstantAlert;
  final Future<void> Function() onRetry;

  const NotificationSettingsSection({
    super.key,
    required this.settings,
    required this.onToggleInstantAlert,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return settings.when(
      data: (settings) {
        return SettingsSection(
          title: '알림 설정',
          children: [
            SettingRow(
              title: '리포트 발행 알림 받기',
              subtitle: '캠모드에서 촬영을 종료하면 자동으로 리포트가 발행돼요.',
              trailing: OnOffButton(
                value: settings.instantAlert,
                onChanged: (value) => onToggleInstantAlert(value),
              ),
            ),
          ],
        );
      },
      loading: () => SettingsSection(
        title: '알림 설정',
        children: [
          _LoadingRow(title: '리포트 발행 알림 불러오는 중...'),
          AppConstants.h8,
        ],
      ),
      error: (error, _) => SettingsSection(
        title: '알림 설정',
        children: [
          Padding(
            padding: EdgeInsets.all(AppConstants.defaultSpacing),
            child: Text(
              '알림 설정을 불러오지 못했습니다.\n잠시 후 다시 시도해주세요.',
              style: const TextStyle(
                color: AppColors.errorRed,
                fontSize: AppConstants.defaultFontSize,
              ),
            ),
          ),
          TextButton(
            onPressed: () => onRetry(),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}

class _LoadingRow extends StatelessWidget {
  final String title;

  const _LoadingRow({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        AppConstants.w12,
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.grey7,
            ),
          ),
        ),
      ],
    );
  }
}