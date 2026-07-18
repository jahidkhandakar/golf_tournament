import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/user/user_tier.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    this.name = 'Jahid',
    this.tier = UserTier.free,
    this.handicap = 7.4,
    this.homeClub = 'Riverbend Golf Club',
  });

  final String name;
  final UserTier tier;
  final double handicap;
  final String homeClub;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.gold,
            child: Icon(Icons.person, color: AppColors.white, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.heading2(primaryText)),
                const SizedBox(height: 4),
                Text('Handicap ${handicap.toStringAsFixed(1)}', style: AppTextStyles.body(secondaryText)),
                Row(
                  children: [
                    Icon(Icons.sports_golf_outlined, size: 14, color: secondaryText),
                    const SizedBox(width: 4),
                    Text(homeClub, style: AppTextStyles.caption(secondaryText)),
                  ],
                ),
                const SizedBox(height: 6),
                Chip(
                  label: Text(tier.label, style: AppTextStyles.caption(AppColors.white)),
                  backgroundColor: tier.color,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
