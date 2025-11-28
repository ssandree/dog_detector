import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/models/notification_models.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/onoff_button.dart';
import 'setting_row.dart';

class NotificationSettingsSection extends StatefulWidget {
  final AsyncValue<NotificationSettings> settings;
  final Future<void> Function(bool value) onToggleInstantAlert;

  const NotificationSettingsSection({
    super.key,
    required this.settings,
    required this.onToggleInstantAlert,
  });

  @override
  State<NotificationSettingsSection> createState() => _NotificationSettingsSectionState();
}

class _NotificationSettingsSectionState extends State<NotificationSettingsSection> {
  bool? _localEnabled;

  @override
  Widget build(BuildContext context) {
    // settings에서 현재 값을 가져와서 로컬 상태 초기화
    final currentEnabled = widget.settings.value?.instantAlert ?? false;
    final enabled = _localEnabled ?? currentEnabled;

    return SettingsSection(
      title: '알림 설정',
      children: [
        SettingRow(
          title: '리포트 발행 알림 받기',
          subtitle: '캠모드에서 촬영을 종료하면 자동으로 리포트가 발행돼요.',
          trailing: OnOffButton(
            value: enabled,
            onChanged: (value) async {
              // 즉시 UI 업데이트
              setState(() {
                _localEnabled = value;
              });

              try {
                await widget.onToggleInstantAlert(value);
                if (mounted) {
                  AppToast.success(
                    context,
                    value ? '리포트 발행 알림이 켜졌어요' : '리포트 발행 알림이 꺼졌어요',
                  );
                }
              } catch (e) {
                // 에러 발생 시 이전 값으로 되돌림
                setState(() {
                  _localEnabled = null;
                });
                if (mounted) {
                  AppToast.error(
                    context,
                    '알림 설정 변경에 실패했습니다. 다시 시도해주세요.',
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }
}