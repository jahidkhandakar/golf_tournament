import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/app_notification.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.requestAccepted:
        return Icons.check_circle_outline;
      case NotificationType.teeTimePosted:
        return Icons.calendar_today_outlined;
      case NotificationType.newChallenge:
        return Icons.emoji_events_outlined;
      case NotificationType.clubInvite:
        return Icons.group_add_outlined;
      case NotificationType.newMessage:
        return Icons.chat_bubble_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppColors.gold.withValues(alpha: 0.16),
        child: Icon(_iconFor(notification.type), color: AppColors.goldDark),
      ),
      title: Text(
        notification.text,
        style: notification.isRead ? AppTextStyles.body(primaryText) : AppTextStyles.bodyBold(primaryText),
      ),
      subtitle: Text(formatRelativeShort(notification.timestamp), style: AppTextStyles.caption(secondaryText)),
      trailing: notification.isRead
          ? null
          : const CircleAvatar(radius: 4, backgroundColor: AppColors.gold),
    );
  }
}
