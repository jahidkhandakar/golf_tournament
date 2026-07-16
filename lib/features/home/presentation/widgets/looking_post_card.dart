import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/tag_chip.dart';
import '../../domain/entities/looking_post.dart';

class LookingPostCard extends StatelessWidget {
  const LookingPostCard({
    super.key,
    required this.post,
    required this.onInvite,
    required this.onMessage,
  });

  final LookingPost post;
  final VoidCallback onInvite;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.gold,
                  child: Text(
                    _initials(post.playerName),
                    style: AppTextStyles.bodyBold(AppColors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.playerName, style: AppTextStyles.bodyBold(primaryText)),
                      Text(post.location, style: AppTextStyles.caption(secondaryText)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final date in post.availableDates) TagChip(label: date),
                for (final format in post.preferredFormats)
                  TagChip(
                    label: format,
                    background: AppColors.gold.withValues(alpha: 0.16),
                    foreground: AppColors.goldDark,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(post.note, style: AppTextStyles.body(secondaryText)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(onPressed: onInvite, child: const Text('Invite to Club')),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(onPressed: onMessage, child: const Text('Message')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
