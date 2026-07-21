import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/photo_avatar.dart';
import '../../domain/entities/conversation.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({super.key, required this.conversation, required this.onTap});

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final hasUnread = conversation.unreadCount > 0;

    return ListTile(
      onTap: onTap,
      leading: PhotoAvatar(name: conversation.participantName, radius: 22),
      title: Text(
        conversation.participantName,
        style: hasUnread ? AppTextStyles.bodyBold(primaryText) : AppTextStyles.body(primaryText),
      ),
      isThreeLine: true,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            conversation.lastMessagePreview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: hasUnread ? AppTextStyles.bodyBold(secondaryText) : AppTextStyles.body(secondaryText),
          ),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 12, color: secondaryText),
              const SizedBox(width: 2),
              Text(
                '${conversation.location} · ${conversation.distanceMiles.toStringAsFixed(0)} mi',
                style: AppTextStyles.caption(secondaryText),
              ),
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(formatRelativeShort(conversation.lastMessageTime), style: AppTextStyles.caption(secondaryText)),
          const SizedBox(height: 6),
          if (hasUnread)
            Badge(label: Text('${conversation.unreadCount}'))
          else
            const SizedBox(height: 18),
        ],
      ),
    );
  }
}
