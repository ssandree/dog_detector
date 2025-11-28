import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/notification_models.dart';
import '../service/notification/mock_notification_service.dart';
import '../service/notification/notification_service.dart';
import '../service/notification/remote_notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  const useMock =
      bool.fromEnvironment('USE_MOCK_NOTIFICATION_SERVICE', defaultValue: false);
  return useMock ? MockNotificationService() : RemoteNotificationService();
});

class NotificationSettingsNotifier
    extends AsyncNotifier<NotificationSettings> {
  @override
  Future<NotificationSettings> build() async {
    final service = ref.read(notificationServiceProvider);
    return service.fetchSettings();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(notificationServiceProvider);
      final settings = await service.fetchSettings();
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleInstantAlert(bool value) async {
    final current = state.value;
    if (current == null) return;
    await _saveSettings(current.copyWith(instantAlert: value));
  }

  Future<void> registerFcmToken(String token) async {
    final service = ref.read(notificationServiceProvider);
    await service.registerFcmToken(token);
    final current = state.value;
    if (current != null) {
      state = AsyncValue.data(current.copyWith(fcmToken: token));
    }
  }

  Future<void> _saveSettings(NotificationSettings settings) async {
    state = AsyncValue.data(settings);
    try {
      final service = ref.read(notificationServiceProvider);
      final saved = await service.updateSettings(settings);
      state = AsyncValue.data(saved);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final notificationSettingsProvider =
    AsyncNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  NotificationSettingsNotifier.new,
);
