import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/widgets/base_scaffold.dart';
import '../../../core/widgets/app_section.dart';
import '../../../core/data/notification_mock.dart';
import 'notification_item.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: '알림',
      showBackButton: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: _NotificationList(
            notifications: mockNotificationMessages,
          ),
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
        mainAxisSize: MainAxisSize.min,
        children: notifications.map((notification) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: NotificationItem(notification: notification),
          );
        }).toList(),
      ),
    );
  }
}
