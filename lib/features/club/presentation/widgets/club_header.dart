import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/club.dart';

class ClubHeader extends StatelessWidget {
  const ClubHeader({super.key, required this.club, this.onSwitch});

  final Club club;

  /// Opens the club switcher (change which of your clubs the tab shows).
  final VoidCallback? onSwitch;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.sports_golf, color: AppColors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(club.name, style: AppTextStyles.heading3(primaryText)),
                const SizedBox(height: 2),
                Text('${club.location} · ${club.memberCount} members', style: AppTextStyles.caption(secondaryText)),
              ],
            ),
          ),
          if (onSwitch != null)
            TextButton.icon(
              onPressed: onSwitch,
              icon: const Icon(Icons.swap_horiz, size: 18),
              label: const Text('Switch'),
            ),
        ],
      ),
    );
  }
}
