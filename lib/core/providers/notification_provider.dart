import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/notification_mock.dart';
import '../../models/notification_message.dart';
import '../services/notification/notification_service.dart';
import '../services/notification/mock_notification_service.dart';
import 'mode_provider.dart';

class NotificationNotifier extends AsyncNotifier<List<NotificationMessage>> {
  late final NotificationService _notificationService;

  @override
  Future<List<NotificationMessage>> build() async {
    _notificationService = ref.watch(notificationServiceProvider);
    return _notificationService.loadNotifications();
  }

  Future<void> refreshNotifications() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _notificationService.loadNotifications());
  }

  Future<void> addNotification(NotificationMessage message) async {
    final current = List<NotificationMessage>.from(state.value ?? await _notificationService.loadNotifications());
    final updated = [message, ...current];
    state = AsyncValue.data(updated);
    await _notificationService.saveNotifications(updated);
  }

  Future<void> markAsRead(String id) async {
    final current = state.value ?? await _notificationService.loadNotifications();
    final updated = current
        .map(
          (notification) => notification.id == id ? notification.copyWith(isRead: true) : notification,
        )
        .toList();
    state = AsyncValue.data(updated);
    await _notificationService.saveNotifications(updated);
  }

  Future<void> markAllAsRead() async {
    final current = state.value ?? await _notificationService.loadNotifications();
    final updated = current.map((notification) => notification.copyWith(isRead: true)).toList();
    state = AsyncValue.data(updated);
    await _notificationService.saveNotifications(updated);
  }

  Future<void> resetToMock() async {
    final mockData = mockNotificationMessages.map((message) => message.copyWith()).toList();
    state = AsyncValue.data(mockData);
    await _notificationService.saveNotifications(mockData);
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final storage = ref.watch(localStorageRepositoryProvider);
  return MockNotificationService(storage);
});

final notificationProvider = AsyncNotifierProvider<NotificationNotifier, List<NotificationMessage>>(
  NotificationNotifier.new,
);

