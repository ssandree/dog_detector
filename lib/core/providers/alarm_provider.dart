import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../models/alarm_info.dart';
import '../services/alarm/alarm_service.dart';
import '../services/alarm/mock_alarm_service.dart';
import 'mode_provider.dart';

/// AlarmInfo 상태를 관리하는 Notifier
/// 
/// 역할:
/// - UI 상태 관리 (AlarmInfo)
/// - Service를 호출하여 알림 설정 로드/저장
/// - 상태 변경 시 UI 자동 업데이트
class AlarmNotifier extends Notifier<AlarmInfo> {
  late final AlarmService _alarmService;

  @override
  AlarmInfo build() {
    _alarmService = ref.watch(alarmServiceProvider);
    // 초기화 시 저장된 알림 설정 로드 (비동기 작업은 별도로 처리)
    Future.microtask(() => loadAlarmSettings());
    return const AlarmInfo();
  }

  /// 알림 설정 로드 (로컬 저장소나 서버에서)
  /// Service를 호출하여 알림 설정을 가져옵니다.
  Future<void> loadAlarmSettings() async {
    try {
      final alarmInfo = await _alarmService.loadSettings();
      state = alarmInfo;
    } catch (e) {
      // 에러 발생 시 기본값 유지
      // TODO: 에러 처리 (예: Toast 표시)
    }
  }

  /// 알림 설정 저장
  /// Service를 호출하여 현재 상태를 저장합니다.
  Future<void> saveAlarmSettings() async {
    try {
      await _alarmService.saveSettings(state);
    } catch (e) {
      // TODO: 에러 처리 (예: Toast 표시)
    }
  }

  /// 즉시 알림 설정 변경
  Future<void> setInstantAlert(bool value) async {
    state = state.copyWith(instantAlert: value);
    await saveAlarmSettings();
  }

  /// 하루 요약 알림 설정 변경
  Future<void> setDailySummary(bool value) async {
    state = state.copyWith(dailySummary: value);
    await saveAlarmSettings();
  }

  /// 푸시 알림 시간 설정 변경
  Future<void> setPushTime(TimeOfDay time) async {
    state = state.copyWith(pushTime: time);
    await saveAlarmSettings();
  }

  /// 월간 리포트 설정 변경
  Future<void> setMonthlyReport(bool value) async {
    state = state.copyWith(monthlyReport: value);
    await saveAlarmSettings();
  }

  /// 리포트 전송 이메일 설정 변경
  Future<void> setReportEmail(String email) async {
    state = state.copyWith(reportEmail: email);
    await saveAlarmSettings();
  }

  /// 리포트 전송 날짜 설정 변경
  Future<void> setReportDay(int day) async {
    state = state.copyWith(reportDay: day);
    await saveAlarmSettings();
  }
}

/// AlarmService Provider
final alarmServiceProvider = Provider<AlarmService>((ref) {
  final storage = ref.watch(localStorageRepositoryProvider);
  return MockAlarmService(storage);
});

/// AlarmInfo 상태를 관리하는 Provider
final alarmProvider = NotifierProvider<AlarmNotifier, AlarmInfo>(AlarmNotifier.new);

