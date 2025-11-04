import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/alarm_info.dart';
import '../services/local_storage_service.dart';
import '../core/exceptions.dart';

/// 알림 설정 관련 비즈니스 로직을 처리하는 Service
/// 
/// 역할:
/// - 알림 설정 로드/저장 (SharedPreferences)
/// - Mock 데이터를 Model로 변환
/// - 에러를 적절한 Exception으로 변환
class AlarmService {
  final LocalStorageService _storage;

  AlarmService(this._storage);

  /// 알림 설정 로드
  /// 
  /// 반환값: AlarmInfo 객체
  /// 예외: NetworkException, DataException
  Future<AlarmInfo> loadAlarmSettings() async {
    try {
      final jsonString = await _storage.getAlarmSettings();
      
      if (jsonString != null) {
        // 저장된 설정이 있으면 불러오기
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return alarmInfoFromJson(json);
      }

      // 저장된 설정이 없으면 기본값 반환
      return const AlarmInfo(
        instantAlert: true,
        dailySummary: true,
        pushTime: TimeOfDay(hour: 20, minute: 0),
        monthlyReport: true,
        reportEmail: 'user@example.com',
        reportDay: 1,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DataException(
        '알림 설정을 불러오는데 실패했습니다.',
        e,
      );
    }
  }

  /// 알림 설정 저장
  /// 
  /// [alarmInfo]: 저장할 알림 설정
  /// 예외: NetworkException, DataException
  Future<void> saveAlarmSettings(AlarmInfo alarmInfo) async {
    try {
      final json = alarmInfoToJson(alarmInfo);
      final jsonString = jsonEncode(json);
      await _storage.saveAlarmSettings(jsonString);
    } on AppException {
      rethrow;
    } catch (e) {
      throw DataException(
        '알림 설정을 저장하는데 실패했습니다.',
        e,
      );
    }
  }

  /// 알림 설정을 JSON으로 변환하여 저장
  /// 
  /// [alarmInfo]: 저장할 알림 설정
  /// 반환값: 저장된 JSON 데이터
  /// 예외: DataException
  Map<String, dynamic> alarmInfoToJson(AlarmInfo alarmInfo) {
    try {
      return alarmInfo.toJson();
    } catch (e) {
      throw DataException(
        '알림 설정을 변환하는데 실패했습니다.',
        e,
      );
    }
  }

  /// JSON 데이터를 AlarmInfo로 변환
  /// 
  /// [json]: 변환할 JSON 데이터
  /// 반환값: AlarmInfo 객체
  /// 예외: DataException
  AlarmInfo alarmInfoFromJson(Map<String, dynamic> json) {
    try {
      return AlarmInfo.fromJson(json);
    } catch (e) {
      throw DataException(
        '알림 설정을 불러오는데 실패했습니다. 데이터 형식이 올바르지 않습니다.',
        e,
      );
    }
  }
}

