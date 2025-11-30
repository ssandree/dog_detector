import '../model/notification_models.dart';

abstract class NotificationService {
  Future<NotificationSettings> fetchSettings();
  Future<NotificationSettings> updateSettings(NotificationSettings settings);
  Future<void> registerFcmToken(String token);
  Future<List<NotificationMessage>> fetchMessages();
  Future<void> toggleNotification(bool enabled);
}

