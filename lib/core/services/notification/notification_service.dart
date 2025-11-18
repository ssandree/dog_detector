import '../../../models/notification_message.dart';

abstract class NotificationService {
  Future<List<NotificationMessage>> loadNotifications();
  Future<void> saveNotifications(List<NotificationMessage> notifications);
  Future<void> clearNotifications();
}

