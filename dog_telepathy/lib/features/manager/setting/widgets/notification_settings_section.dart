import 'package:flutter/material.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/app_constants.dart';
import '../../../../core/widgets/onoff_button.dart';
import 'setting_row.dart';
import 'time_picker_modal.dart';
import 'day_picker_modal.dart';

/// 알림 설정 섹션
class NotificationSettingsSection extends StatefulWidget {
  const NotificationSettingsSection({super.key});

  @override
  State<NotificationSettingsSection> createState() => _NotificationSettingsSectionState();
}

class _NotificationSettingsSectionState extends State<NotificationSettingsSection> {
  bool _instantAlert = true;
  bool _dailySummary = true;
  TimeOfDay _pushTime = const TimeOfDay(hour: 20, minute: 0);
  bool _monthlyReport = false;
  int _reportDay = 1;

  String get _formattedPushTime {
    final hour = _pushTime.hour;
    final minute = _pushTime.minute;
    final period = hour >= 12 ? '오후' : '오전';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$period $displayHour:${minute.toString().padLeft(2, '0')}';
  }

  String get _formattedReportDay {
    return '매월 $_reportDay일';
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: '알림 설정',
      children: [
        SettingRow(
          title: '즉시 알림 받기',
          subtitle: '강아지의 감정이 감지되면 즉시 알림을 받을 수 있어요',
          trailing: OnOffButton(
            value: _instantAlert,
            onChanged: (v) => setState(() => _instantAlert = v),
          ),
        ),
        SettingRow(
          title: '하루 요약 알림 받기',
          subtitle: '오늘 하루 강아지 리포트를 받을 수 있어요',
          trailing: OnOffButton(
            value: _dailySummary,
            onChanged: (v) => setState(() => _dailySummary = v),
          ),
        ),
        ActionRow(
          title: '푸시 알림 시간',
          trailingText: _formattedPushTime,
          onTap: () => _pickTime(context),
        ),
        SettingRow(
          title: '월간 리포트 받기',
          subtitle: '한 달에 한 번 강아지 리포트를 받을 수 있어요',
          trailing: OnOffButton(
            value: _monthlyReport,
            onChanged: (v) => setState(() => _monthlyReport = v),
          ),
        ),
        ActionRow(
          title: '리포트 전송 날짜',
          trailingText: _formattedReportDay,
          onTap: () => _pickDay(context),
        ),
      ],
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final result = await TimePickerModal.show(
      context: context,
      initialTime: _pushTime,
      helpText: '푸시 알림 시간',
    );
    if (result != null) {
      setState(() => _pushTime = result);
    }
  }

  Future<void> _pickDay(BuildContext context) async {
    final result = await DayPickerModal.show(
      context: context,
      currentDay: _reportDay,
      title: '리포트 전송 날짜 선택',
    );
    if (result != null) {
      setState(() => _reportDay = result);
    }
  }
}

