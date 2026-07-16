import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/nearby_golfer.dart';

class GolferTile extends StatelessWidget {
  const GolferTile({super.key, required this.golfer, required this.onTap});

  final NearbyGolfer golfer;
  final VoidCallback onTap;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) return parts.isEmpty ? '?' : parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.gold,
                child: Text(_initials(golfer.name), style: AppTextStyles.heading3(AppColors.white)),
              ),
              const SizedBox(height: 10),
              Text(
                golfer.name,
                style: AppTextStyles.bodyBold(primaryText),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text('HCP ${golfer.handicap.toStringAsFixed(1)}', style: AppTextStyles.caption(secondaryText)),
              Text('${golfer.distanceMiles.toStringAsFixed(1)} mi away', style: AppTextStyles.caption(secondaryText)),
            ],
          ),
        ),
      ),
    );
  }
}
