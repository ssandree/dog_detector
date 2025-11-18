import '../../../models/notification_message.dart';
import 'notification_service.dart';

class RemoteNotificationService implements NotificationService {
  @override
  Future<List<NotificationMessage>> loadNotifications() {
    throw UnimplementedError();
  }

  @override
  Future<void> saveNotifications(List<NotificationMessage> notifications) {
    throw UnimplementedError();
  }

  @override
  Future<void> clearNotifications() {
    throw UnimplementedError();
  }
}

