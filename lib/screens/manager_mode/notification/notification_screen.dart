import '../../../core/index_export.dart';
import 'widgets/notification_item.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);

    return StandardScaffold(
      title: '알림',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: AsyncValueWidget<List<NotificationMessage>>(
          asyncValue: notificationsAsync,
          onRetry: notifier.refreshNotifications,
          data: (context, notifications) => _NotificationList(
            notifications: notifications,
            onNotificationTap: notifier.markAsRead,
          ),
        ),
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  final List<NotificationMessage> notifications;
  final void Function(String id)? onNotificationTap;

  const _NotificationList({
    required this.notifications,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return AppSection(
        title: '최근 알림',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              '받은 알림이 아직 없어요.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey7,
                  ),
            ),
          ),
        ),
      );
    }

    return AppSection(
      title: '최근 알림',
      child: Column(
        children: List.generate(notifications.length, (index) {
          final notification = notifications[index];
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: index == 0 ? 16 : 12,
              bottom: index == notifications.length - 1 ? 16 : 12,
            ),
            child: GestureDetector(
              onTap: () => onNotificationTap?.call(notification.id),
              child: NotificationItem(notification: notification),
            ),
          );
        }),
      ),
    );
  }
}
