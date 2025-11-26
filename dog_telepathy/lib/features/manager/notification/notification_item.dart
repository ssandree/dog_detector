import 'package:flutter/material.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/app_constants.dart';
import '../../../../core/data/notification_mock.dart';

class NotificationItem extends StatelessWidget {
  final NotificationMessage notification;

  const NotificationItem({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.grey12,
          fontSize: 14,
        );
    final bodyStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.grey8,
          height: 1.3,
          fontSize: 12,
        );
    final timeStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.grey6,
          fontSize: 10,
        );
    final timeLabel = _formatTimeLabel(notification.sentAt);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: notification.isRead ? AppColors.grey1 : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey3),
        boxShadow: notification.isRead
            ? null
            : [
                BoxShadow(
                  color: AppColors.grey3.withValues(alpha: 0.6),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: titleStyle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timeLabel,
                style: timeStyle,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            notification.body,
            style: bodyStyle,
          ),
        ],
      ),
    );
  }

  String _formatTimeLabel(DateTime sentAt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sentDate = DateTime(sentAt.year, sentAt.month, sentAt.day);
    final difference = today.difference(sentDate).inDays;

    final period = sentAt.hour < 12 ? '오전' : '오후';
    final hour = sentAt.hour % 12 == 0 ? 12 : sentAt.hour % 12;
    final minute = sentAt.minute.toString().padLeft(2, '0');
    final time = '$period $hour:$minute';

    if (difference == 0) {
      return '오늘 · $time';
    } else if (difference == 1) {
      return '어제 · $time';
    } else if (difference < 7) {
      return '${difference}일 전 · $time';
    } else {
      final month = sentAt.month.toString().padLeft(2, '0');
      final day = sentAt.day.toString().padLeft(2, '0');
      return '${sentAt.year}.$month.$day';
    }
  }
}

