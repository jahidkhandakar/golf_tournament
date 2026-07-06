import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// "Gaggles near [zone] · [radius] mi" context line shown under the banner.
class ZoneContextLine extends StatelessWidget {
  const ZoneContextLine({super.key, required this.zone, required this.radiusMiles});

  final String zone;
  final int radiusMiles;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, size: 16, color: color),
          const SizedBox(width: 4),
          Text('Gaggles near $zone · $radiusMiles mi', style: AppTextStyles.caption(color)),
        ],
      ),
    );
  }
}
