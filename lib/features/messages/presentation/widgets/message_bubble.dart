import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bubbleColor = message.isMine
        ? AppColors.gold.withValues(alpha: isDark ? 0.35 : 0.22)
        : (isDark ? AppColors.darkSurface : AppColors.greyLight.withValues(alpha: 0.6));
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message.text, style: AppTextStyles.body(textColor)),
            const SizedBox(height: 4),
            Text(formatRelativeShort(message.timestamp), style: AppTextStyles.caption(secondaryText)),
          ],
        ),
      ),
    );
  }
}
