import '../../../core/index_export.dart';
import 'widgets/pet_profile.dart';
import 'widgets/time_picker_modal.dart';
import 'widgets/email_editor_modal.dart';
import 'widgets/day_picker_modal.dart';
import 'widgets/settings_section.dart';
import 'widgets/setting_row.dart';

class SettingScreen extends ConsumerWidget {
   const SettingScreen({super.key});

   @override
   Widget build(BuildContext context, WidgetRef ref) {
      final alarmInfo = ref.watch(alarmProvider);
      final alarmNotifier = ref.read(alarmProvider.notifier);

      return BaseScaffold(
         title: '환경설정',
        body: SingleChildScrollView(
          child: HorizontalPadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
               // PetProfile은 높이 제약이 있으므로 그대로 사용
               const PetProfile(),
               AppConstants.h12,

               SettingsSection(
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
                        title: '리포트 전송 이메일',
                        trailingText: alarmInfo.reportEmail,
                        onTap: () => _editEmail(context, alarmInfo.reportEmail, alarmNotifier),
                     ),
                     ActionRow(
                        title: '리포트 전송 날짜',
                        trailingText: alarmInfo.formattedReportDay,
                        onTap: () => _pickDay(context, alarmInfo.reportDay, alarmNotifier),
                     ),
                  ],
               ),

               AppConstants.h16,
               SettingsSection(
                  title: '데이터 관리',
                  children: [
                     ActionRow(
                        title: '저장된 영상 보기',
                        subtitle: '저장한 영상을 볼 수 있어요',
                        onTap: () => _showSnack(context, '저장된 영상을 준비 중입니다.'),
                     ),
                  ],
               ),

               AppConstants.h16,
               SettingsSection(
                  title: '계정 관리',
                  children: [
                     ActionRow(
                        title: '로그인',
                        trailingText: '2020020@gmail.com',
                     ),
                     ActionRow(
                        title: '현재 기기 모드 재설정',
                        subtitle: '매니저모드와 캠모드 중 선택',
                        onTap: () => _resetMode(context, ref),
                     ),
                     // 연결된 기기는 높이 제한 없이 표시
                     Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        constraints: const BoxConstraints(
                          minHeight: 60,
                          maxHeight: double.infinity,
                        ),
                        child: Row(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                              Expanded(
                                 child: Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                          const Text('연결된 기기', style: TextStyle(fontSize: 16)),
                                          Padding(
                                             padding: const EdgeInsets.only(top: 4),
                                             child: Text(
                                                '닉네임1(기기이름):매니저 모드\n닉네임2(기기이름):캠모드',
                                                style: TextStyle(fontSize: 12, color: AppColors.grey8),
                                                maxLines: 5,
                                                overflow: TextOverflow.ellipsis,
                                             ),
                                          ),
                                       ],
                                    ),
                                 ),
                              ),
                           ],
                        ),
                     ),
                  ],
               ),
               const SizedBox(height: 16),
            ],
          ),
        ),
      ),
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

   Future<void> _editEmail(BuildContext context, String initialEmail, AlarmNotifier notifier) async {
      final result = await EmailEditorModal.show(
         context: context,
         initialEmail: initialEmail,
         title: '리포트 전송 이메일',
         hintText: '이메일 입력',
      );
      if (result != null) {
         await notifier.setReportEmail(result);
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

   void _resetMode(BuildContext context, WidgetRef ref) {
      // 모드 리셋 후 메인 화면으로 이동
      ref.read(appModeProvider.notifier).resetMode();
      context.go(AppRoutes.modeSelect);
   }

   void _showSnack(BuildContext context, String message) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(message)),
      );
   }
}

