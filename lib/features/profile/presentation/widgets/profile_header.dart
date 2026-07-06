import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/user/user_tier.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    this.name = 'John Doe',
    this.tier = UserTier.free,
    this.handicap = 14.2,
  });

  final String name;
  final UserTier tier;
  final double handicap;

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
