import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/index_export.dart';
import 'setting_row.dart';
import 'time_picker_modal.dart';
import 'day_picker_modal.dart';

/// 알림 설정 섹션
/// 
/// AlarmProvider를 직접 사용하여 알림 관련 모든 설정을 관리합니다.
class NotificationSettingsSection extends ConsumerWidget {
  const NotificationSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarmInfo = ref.watch(alarmProvider);
    final alarmNotifier = ref.read(alarmProvider.notifier);

    return SettingsSection(
      title: '알림 설정',
      children: [
        SettingRow(
          title: '즉시 알림 받기',
          subtitle: '강아지의 감정이 감지되면 즉시 알림을 받을 수 있어요',
          trailing: OnOffButton(
            value: alarmInfo.instantAlert,
            onChanged: (v) => alarmNotifier.setInstantAlert(v),
          ),
        ),
        SettingRow(
          title: '하루 요약 알림 받기',
          subtitle: '오늘 하루 강아지 리포트를 받을 수 있어요',
          trailing: OnOffButton(
            value: alarmInfo.dailySummary,
            onChanged: (v) => alarmNotifier.setDailySummary(v),
          ),
        ),
        ActionRow(
          title: '푸시 알림 시간',
          trailingText: alarmInfo.formattedPushTime,
          onTap: () => _pickTime(context, alarmInfo.pushTime, alarmNotifier),
        ),
        SettingRow(
          title: '월간 리포트 받기',
          subtitle: '한 달에 한 번 강아지 리포트를 받을 수 있어요',
          trailing: OnOffButton(
            value: alarmInfo.monthlyReport,
            onChanged: (v) => alarmNotifier.setMonthlyReport(v),
          ),
        ),
        ActionRow(
          title: '리포트 전송 날짜',
          trailingText: alarmInfo.formattedReportDay,
          onTap: () => _pickDay(context, alarmInfo.reportDay, alarmNotifier),
        ),
      ],
    );
  }

  Future<void> _pickTime(BuildContext context, TimeOfDay initialTime, AlarmNotifier notifier) async {
    final result = await TimePickerModal.show(
      context: context,
      initialTime: initialTime,
      helpText: '푸시 알림 시간',
    );
    if (result != null) {
      await notifier.setPushTime(result);
    }
  }

  Future<void> _pickDay(BuildContext context, int currentDay, AlarmNotifier notifier) async {
    final result = await DayPickerModal.show(
      context: context,
      currentDay: currentDay,
      title: '리포트 전송 날짜 선택',
    );
    if (result != null) {
      await notifier.setReportDay(result);
    }
  }
}

