import '../../../models/alarm_info.dart';

abstract class AlarmService {
  Future<AlarmInfo> loadSettings();
  Future<void> saveSettings(AlarmInfo alarmInfo);
  Future<void> clearSettings();
}

