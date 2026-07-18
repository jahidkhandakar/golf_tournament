import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A club's photo gallery (placeholder thumbnails). The number of photos is
/// derived from the club so switching clubs shows a different-sized gallery.
class GalleryTab extends StatelessWidget {
  const GalleryTab({super.key, required this.clubName});

  final String clubName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    // 6–14 placeholder photos, deterministic per club.
    final photoCount = 6 + (clubName.hashCode.abs() % 9);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Icon(Icons.photo_library_outlined, size: 16, color: secondaryText),
              const SizedBox(width: 4),
              Text('$photoCount photos', style: AppTextStyles.caption(secondaryText)),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: photoCount,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Photo viewer coming soon (mock)')),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.image_outlined, color: AppColors.gold),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
