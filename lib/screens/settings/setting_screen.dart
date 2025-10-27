import 'package:flutter/material.dart';
import '../../core/index_export.dart';
import '../../data/settings_mock.dart';
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
   // 알림 설정 상태
   bool _instantAlert = true;
   bool _dailySummary = true;
   TimeOfDay _pushTime = const TimeOfDay(hour: 20, minute: 0);
   bool _monthlyReport = true;
   String _reportEmail = 'user@example.com';
   int _reportDay = 1;

   // 포맷된 시간 문자열
   String get _formattedPushTime {
     return '${_pushTime.hour.toString().padLeft(2, '0')}:${_pushTime.minute.toString().padLeft(2, '0')}';
   }

   // 포맷된 리포트 발송일 문자열
   String get _formattedReportDay {
     return '매월 $_reportDay일';
   }

   @override
   void initState() {
      super.initState();
      // 알림 설정 로드
      _loadAlarmSettings();
   }

   // 알림 설정 로드 (로컬 저장소나 서버에서)
   Future<void> _loadAlarmSettings() async {
     // TODO: 실제 저장소에서 설정 로드
     await Future.delayed(const Duration(milliseconds: 500)); // 로딩 시뮬레이션
     
     // Mock 데이터로 초기화
     if (mounted) {
       setState(() {
         _instantAlert = true;
         _dailySummary = true;
         _pushTime = const TimeOfDay(hour: 20, minute: 0);
         _monthlyReport = true;
         _reportEmail = 'user@example.com';
         _reportDay = 1;
       });
     }
   }

   // 알림 설정 저장
   Future<void> _saveAlarmSettings() async {
     // TODO: 실제 저장소에 설정 저장
     await Future.delayed(const Duration(milliseconds: 500)); // 저장 시뮬레이션
   }

   @override
   Widget build(BuildContext context) {
      return BaseScaffold(
         title: '환경설정',
         appBarTheme: AppBarThemeType.white,
         body: SingleChildScrollView(
         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               const PetProfile(),
               AppConstants.h12,

               SettingsSection(
                  title: '알림 설정',
                  children: [
                     SettingRow(
                        title: '즉시 알림 받기',
                        subtitle: '강아지의 감정이 감지되면 즉시 알림을 받을 수 있어요',
                        trailing: OnOffButton(
                           value: _instantAlert,
                           onChanged: (v) async {
                             setState(() {
                               _instantAlert = v;
                             });
                             await _saveAlarmSettings();
                           },
                        ),
                     ),
                     SettingRow(
                        title: '하루 요약 알림 받기',
                        subtitle: '오늘 하루 강아지 리포트를 받을 수 있어요',
                        trailing: OnOffButton(
                           value: _dailySummary,
                           onChanged: (v) async {
                             setState(() {
                               _dailySummary = v;
                             });
                             await _saveAlarmSettings();
                           },
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
                           onChanged: (v) async {
                             setState(() {
                               _monthlyReport = v;
                             });
                             await _saveAlarmSettings();
                           },
                        ),
                     ),
                     ActionRow(
                        title: '리포트 전송 이메일',
                        trailingText: _reportEmail,
                        onTap: () => _editEmail(context),
                     ),
                     ActionRow(
                        title: '리포트 전송 날짜',
                        trailingText: _formattedReportDay,
                        onTap: () => _pickDay(context),
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
   }

   Future<void> _pickTime(BuildContext context) async {
      final result = await TimePickerModal.show(
         context: context,
         initialTime: _pushTime,
         helpText: '푸시 알림 시간',
      );
      if (result != null) {
         setState(() {
           _pushTime = result;
         });
         await _saveAlarmSettings();
      }
   }

   Future<void> _editEmail(BuildContext context) async {
      final result = await EmailEditorModal.show(
         context: context,
         initialEmail: _reportEmail,
         title: '리포트 전송 이메일',
         hintText: '이메일 입력',
      );
      if (result != null) {
         setState(() {
           _reportEmail = result;
         });
         await _saveAlarmSettings();
      }
   }

   Future<void> _pickDay(BuildContext context) async {
      final result = await DayPickerModal.show(
         context: context,
         currentDay: _reportDay,
         title: '리포트 전송 날짜 선택',
      );
      if (result != null) {
         setState(() {
           _reportDay = result;
         });
         await _saveAlarmSettings();
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

