import 'package:flutter/material.dart';

import '../../../../core/assets/app_images.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/nearby_golfer.dart';

class GolferTile extends StatelessWidget {
  const GolferTile({super.key, required this.golfer, required this.onTap});

  final NearbyGolfer golfer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.asset(
                AppImages.person(golfer.name),
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.2),
                cacheWidth: 400,
                errorBuilder: (context, error, stackTrace) => Container(color: AppColors.gold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    golfer.name,
                    style: AppTextStyles.bodyBold(primaryText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'HCP ${golfer.handicap.toStringAsFixed(1)} · ${golfer.distanceMiles.toStringAsFixed(0)} mi',
                    style: AppTextStyles.caption(secondaryText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
