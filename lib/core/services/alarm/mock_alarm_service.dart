import 'package:flutter/material.dart';

import '../../../models/alarm_info.dart';
import '../../exceptions.dart';
import '../../storage/local_storage_keys.dart';
import '../../storage/local_storage_repository.dart';
import 'alarm_service.dart';

class MockAlarmService implements AlarmService {
  final LocalStorageRepository _storage;

  MockAlarmService(this._storage);

  @override
  Future<AlarmInfo> loadSettings() async {
    try {
      final json = await _storage.loadJson(LocalStorageKeys.alarmSettings);
      if (json != null) {
        return AlarmInfo.fromJson(json);
      }
      return _defaultSettings;
    } on AppException {
      rethrow;
    } catch (e) {
      throw DataException(
        '알림 설정을 불러오는데 실패했습니다.',
        e,
      );
    }
  }

  @override
  Future<void> saveSettings(AlarmInfo alarmInfo) async {
    try {
      await _storage.saveJson(LocalStorageKeys.alarmSettings, alarmInfo.toJson());
    } catch (e) {
      throw DataException(
        '알림 설정을 저장하는데 실패했습니다.',
        e,
      );
    }
  }

  @override
  Future<void> clearSettings() async {
    try {
      await _storage.remove(LocalStorageKeys.alarmSettings);
    } catch (e) {
      throw DataException(
        '알림 설정을 삭제하는데 실패했습니다.',
        e,
      );
    }
  }

  AlarmInfo get _defaultSettings => const AlarmInfo(
        instantAlert: true,
        dailySummary: true,
        pushTime: TimeOfDay(hour: 20, minute: 0),
        monthlyReport: true,
        reportEmail: 'user@example.com',
        reportDay: 1,
      );
}

