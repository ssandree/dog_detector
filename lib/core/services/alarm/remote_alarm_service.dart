import '../../../models/alarm_info.dart';
import 'alarm_service.dart';

class RemoteAlarmService implements AlarmService {
  @override
  Future<AlarmInfo> loadSettings() {
    throw UnimplementedError();
  }

  @override
  Future<void> saveSettings(AlarmInfo alarmInfo) {
    throw UnimplementedError();
  }

  @override
  Future<void> clearSettings() {
    throw UnimplementedError();
  }
}

