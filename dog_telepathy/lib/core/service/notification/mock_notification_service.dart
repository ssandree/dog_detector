import 'dart:async';

import '../../data/notification_mock.dart';
import '../../models/notification_models.dart';
import 'notification_service.dart';

class MockNotificationService implements NotificationService {
  NotificationSettings _settings = mockNotificationSettings;

  @override
  Future<NotificationSettings> fetchSettings() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _settings;
  }

  @override
  Future<List<NotificationMessage>> fetchMessages() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return mockNotificationMessages;
  }

  @override
  Future<void> registerFcmToken(String token) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _settings = _settings.copyWith(fcmToken: token);
  }

  @override
  Future<NotificationSettings> updateSettings(NotificationSettings settings) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _settings = settings;
    return _settings;
  }

  @override
  Future<void> toggleNotification(bool enabled) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _settings = _settings.copyWith(instantAlert: enabled);
  }
}
