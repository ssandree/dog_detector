import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/index_export.dart';
import '../../data/settings_mock.dart';
import '../../providers/alarm_providers.dart';
import '../main/main_screen.dart';
import 'widgets/pet_profile.dart';
import 'widgets/time_picker_modal.dart';
import 'widgets/email_editor_modal.dart';
import 'widgets/day_picker_modal.dart';
import 'widgets/settings_section.dart';
import 'widgets/setting_row.dart';

class SettingScreen extends StatefulWidget {
   const SettingScreen({super.key});

   @override
   State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
   @override
   void initState() {
      super.initState();
      // 알림 설정 로드
      WidgetsBinding.instance.addPostFrameCallback((_) {
         context.read<AlarmProvider>().loadAlarmSettings();
      });
   }

   @override
   Widget build(BuildContext context) {
      return Consumer<AlarmProvider>(
         builder: (context, alarmProvider, child) {
            return BaseScaffold(
               title: '환경설정',
               appBarTheme: AppBarThemeType.white,
               body: SingleChildScrollView(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
               child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                     const PetProfile(),
                     const SizedBox(height: 12),

                     SettingsSection(
                        title: '알림 설정',
                        children: [
                           SettingRow(
                              title: '즉시 알림 받기',
                              subtitle: '강아지의 감정이 감지되면 즉시 알림을 받을 수 있어요',
                              trailing: OnOffButton(
                                 value: alarmProvider.instantAlert,
                                 onChanged: (v) => alarmProvider.updateInstantAlert(v),
                              ),
                           ),
                           SettingRow(
                              title: '하루 요약 알림 받기',
                              subtitle: '오늘 하루 강아지 리포트를 받을 수 있어요',
                              trailing: OnOffButton(
                                 value: alarmProvider.dailySummary,
                                 onChanged: (v) => alarmProvider.updateDailySummary(v),
                              ),
                           ),
                           ActionRow(
                              title: '푸시 알림 시간',
                              trailingText: alarmProvider.formattedPushTime,
                              onTap: () => _pickTime(context, alarmProvider),
                           ),
                           SettingRow(
                              title: '월간 리포트 받기',
                              subtitle: '한 달에 한 번 강아지 리포트를 받을 수 있어요',
                              trailing: OnOffButton(
                                 value: alarmProvider.monthlyReport,
                                 onChanged: (v) => alarmProvider.updateMonthlyReport(v),
                              ),
                           ),
                           ActionRow(
                              title: '리포트 전송 이메일',
                              trailingText: alarmProvider.reportEmail,
                              onTap: () => _editEmail(context, alarmProvider),
                           ),
                           ActionRow(
                              title: '리포트 전송 날짜',
                              trailingText: alarmProvider.formattedReportDay,
                              onTap: () => _pickDay(context, alarmProvider),
                           ),
                        ],
                     ),

                     const SizedBox(height: 16),
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

                     const SizedBox(height: 16),
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
                              onTap: () => _resetMode(context),
                           ),
                           // 연결된 기기는 높이 제한 없이 표시
                           Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Row(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                    Expanded(
                                       child: Padding(
                                          padding: const EdgeInsets.only(left: 0),
                                          child: Column(
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                             children: [
                                                Text('연결된 기기', style: const TextStyle(fontSize: 16)),
                                                Padding(
                                                   padding: const EdgeInsets.only(top: 4),
                                                   child: Text(
                                                      '닉네임1(기기이름):매니저 모드\n닉네임2(기기이름):캠모드',
                                                      style: const TextStyle(fontSize: 12, color: AppColors.grey8),
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
            );
         },
      );
   }

   Future<void> _pickTime(BuildContext context, AlarmProvider alarmProvider) async {
      final result = await TimePickerModal.show(
         context: context,
         initialTime: alarmProvider.pushTime,
         helpText: '푸시 알림 시간',
      );
      if (result != null) {
         alarmProvider.updatePushTime(result);
         await alarmProvider.saveAlarmSettings();
      }
   }

   Future<void> _editEmail(BuildContext context, AlarmProvider alarmProvider) async {
      final result = await EmailEditorModal.show(
         context: context,
         initialEmail: alarmProvider.reportEmail,
         title: '리포트 전송 이메일',
         hintText: '이메일 입력',
      );
      if (result != null) {
         alarmProvider.updateReportEmail(result);
         await alarmProvider.saveAlarmSettings();
      }
   }

   Future<void> _pickDay(BuildContext context, AlarmProvider alarmProvider) async {
      final result = await DayPickerModal.show(
         context: context,
         currentDay: alarmProvider.reportDay,
         title: '리포트 전송 날짜 선택',
      );
      if (result != null) {
         alarmProvider.updateReportDay(result);
         await alarmProvider.saveAlarmSettings();
      }
   }

   void _resetMode(BuildContext context) {
      AppUtils.navigateTo(
         context,
         const MainScreen(),
         replace: true,
      );
   }

   void _showSnack(BuildContext context, String message) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(message)),
      );
   }
}

