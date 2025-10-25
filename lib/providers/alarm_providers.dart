import 'package:flutter/material.dart';
import '../models/alarm_info.dart';

class AlarmProvider extends ChangeNotifier {
  // 즉시 알림 설정
  bool _instantAlert = true;
  
  // 일일 요약 알림 설정
  bool _dailySummary = true;
  
  // 푸시 알림 시간
  TimeOfDay _pushTime = const TimeOfDay(hour: 20, minute: 0);
  
  // 월간 리포트 알림 설정
  bool _monthlyReport = true;
  
  // 리포트 이메일 주소
  String _reportEmail = '';
  
  // 리포트 발송일
  int _reportDay = 1; // 매월 1일

  // Getters
  bool get instantAlert => _instantAlert;
  bool get dailySummary => _dailySummary;
  TimeOfDay get pushTime => _pushTime;
  bool get monthlyReport => _monthlyReport;
  String get reportEmail => _reportEmail;
  int get reportDay => _reportDay;

  // 포맷된 시간 문자열
  String get formattedPushTime {
    return '${_pushTime.hour.toString().padLeft(2, '0')}:${_pushTime.minute.toString().padLeft(2, '0')}';
  }

  // 포맷된 리포트 발송일 문자열
  String get formattedReportDay {
    return '매월 $_reportDay일';
  }

  // 즉시 알림 설정 업데이트
  void updateInstantAlert(bool value) {
    _instantAlert = value;
    notifyListeners();
  }

  // 일일 요약 알림 설정 업데이트
  void updateDailySummary(bool value) {
    _dailySummary = value;
    notifyListeners();
  }

  // 푸시 알림 시간 업데이트
  void updatePushTime(TimeOfDay time) {
    _pushTime = time;
    notifyListeners();
  }

  // 월간 리포트 알림 설정 업데이트
  void updateMonthlyReport(bool value) {
    _monthlyReport = value;
    notifyListeners();
  }

  // 리포트 이메일 주소 업데이트
  void updateReportEmail(String email) {
    _reportEmail = email;
    notifyListeners();
  }

  // 리포트 발송일 업데이트
  void updateReportDay(int day) {
    if (day >= 1 && day <= 28) { // 1일부터 28일까지만 허용
      _reportDay = day;
      notifyListeners();
    }
  }

  // 알림 설정 로드 (로컬 저장소나 서버에서)
  Future<void> loadAlarmSettings() async {
    // TODO: 실제 저장소에서 설정 로드
    await Future.delayed(const Duration(milliseconds: 500)); // 로딩 시뮬레이션
    
    // Mock 데이터로 초기화
    _instantAlert = true;
    _dailySummary = true;
    _pushTime = const TimeOfDay(hour: 20, minute: 0);
    _monthlyReport = true;
    _reportEmail = 'user@example.com';
    _reportDay = 1;
    
    notifyListeners();
  }

  // 알림 설정 저장
  Future<void> saveAlarmSettings() async {
    // TODO: 실제 저장소에 설정 저장
    await Future.delayed(const Duration(milliseconds: 500)); // 저장 시뮬레이션
    
    // 저장 완료 알림
    notifyListeners();
  }

  // 모든 알림 설정 초기화
  void resetAlarmSettings() {
    _instantAlert = true;
    _dailySummary = true;
    _pushTime = const TimeOfDay(hour: 20, minute: 0);
    _monthlyReport = true;
    _reportEmail = '';
    _reportDay = 1;
    notifyListeners();
  }

  // 알림 설정을 AlarmInfo 객체로 변환
  AlarmInfo toAlarmInfo() {
    return AlarmInfo(
      instantAlert: _instantAlert,
      dailySummary: _dailySummary,
      pushTime: _pushTime,
      monthlyReport: _monthlyReport,
      reportEmail: _reportEmail,
      reportDay: _reportDay,
    );
  }

  // AlarmInfo 객체에서 알림 설정 로드
  void fromAlarmInfo(AlarmInfo alarmInfo) {
    _instantAlert = alarmInfo.instantAlert;
    _dailySummary = alarmInfo.dailySummary;
    _pushTime = alarmInfo.pushTime;
    _monthlyReport = alarmInfo.monthlyReport;
    _reportEmail = alarmInfo.reportEmail;
    _reportDay = alarmInfo.reportDay;
    notifyListeners();
  }
}
