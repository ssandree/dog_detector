import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/widgets/base_scaffold.dart';
import '../../../core/config/app_constants.dart';
import '../logic/model/notification_models.dart';
import 'notification_item.dart';

// Mock Data
const NotificationSettings mockNotificationSettings = NotificationSettings(
  instantAlert: true,
  fcmToken: 'mock-fcm-token',
);

final List<NotificationMessage> mockNotificationMessages = [
  NotificationMessage(
    id: 'notif-001',
    title: '강아지가 안심하고 쉬고 있어요',
    body: '최근 2시간 동안 스트레스 지수가 안정적으로 유지되고 있어요. 지속적으로 좋은 상태를 유지하고 있습니다.',
    sentAt: DateTime.now().subtract(const Duration(minutes: 18)),
  ),
  NotificationMessage(
    id: 'notif-002',
    title: '산책 추천 알림',
    body: '오늘 낮 12시에 활동량이 낮았어요. 시원해지기 시작하는 지금 산책을 나가보는 건 어떨까요?',
    sentAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
    isRead: true,
  ),
  NotificationMessage(
    id: 'notif-003',
    title: 'AI 리포트 업데이트',
    body: '주간 건강 리포트가 업데이트되었어요. 이번 주에는 행복 지수가 12% 상승했어요!',
    sentAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    isRead: true,
  ),
  NotificationMessage(
    id: 'notif-004',
    title: '알림 설정 안내',
    body: '알림을 원하는 시간대에 맞춰 조정해보세요. 설정 > 알림 관리에서 언제든 변경할 수 있습니다.',
    sentAt: DateTime.now().subtract(const Duration(days: 3, hours: 6)),
    isRead: true,
  ),
];

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: '알림',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.defaultSpacing),
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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            '받은 알림이 아직 없어요.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey7,
                ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '최근 알림',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: notifications.map((notification) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: NotificationItem(notification: notification),
            );
          }).toList(),
        ),
      ],
    );
  }
}

