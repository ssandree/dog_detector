import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../model/notification_models.dart';
import '../service/notification_service.dart';
import '../service/remote_notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return RemoteNotificationService();
});

class NotificationSettingsNotifier
    extends AsyncNotifier<NotificationSettings> {
  @override
  Future<NotificationSettings> build() async {
    // 초기 상태는 기본값으로 설정 (GET 요청 없음)
    // 설정 변경 시에만 PUT 요청을 보냄
    return const NotificationSettings.initial();
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
    try {
      final service = ref.read(notificationServiceProvider);
      await service.toggleNotification(value);
      // 성공 시 로컬 상태 업데이트
      final current = state.value;
      if (current != null) {
        state = AsyncValue.data(current.copyWith(instantAlert: value));
      } else {
        // 상태가 없으면 기본값으로 설정
        state = AsyncValue.data(NotificationSettings(instantAlert: value));
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> registerFcmToken(String token) async {
    final service = ref.read(notificationServiceProvider);
    await service.registerFcmToken(token);
    final current = state.value;
    if (current != null) {
      state = AsyncValue.data(current.copyWith(fcmToken: token));
    }
  }
}

final notificationSettingsProvider =
    AsyncNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  NotificationSettingsNotifier.new,
);
