import '../../../core/index_export.dart';
import '../../../data/notification_mock.dart';
import 'widgets/notification_item.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: '알림',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: _NotificationList(
          notifications: mockNotificationMessages,
        ),
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  final List<NotificationMessage> notifications;

  const _NotificationList({
    required this.notifications,
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
            child: NotificationItem(notification: notification),
          );
        }),
      ),
    );
  }
}
