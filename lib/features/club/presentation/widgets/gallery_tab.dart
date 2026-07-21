import 'package:flutter/material.dart';

import '../../../../core/assets/app_images.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/image_preview.dart';

/// A club's photo gallery — the club's course shot plus community/scene
/// photos. The count is derived from the club so switching clubs shows a
/// different-sized gallery.
class GalleryTab extends StatelessWidget {
  const GalleryTab({super.key, required this.clubName});

  final String clubName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    // 6–12 tiles, deterministic per club. First tile is the club's course.
    final photoCount = 6 + (clubName.hashCode.abs() % 7);
    final paths = <String>[
      AppImages.field(clubName),
      for (var i = 0; i < photoCount - 1; i++) AppImages.scene(i + clubName.hashCode.abs()),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Icon(Icons.photo_library_outlined, size: 16, color: secondaryText),
              const SizedBox(width: 4),
              Text('${paths.length} photos', style: AppTextStyles.caption(secondaryText)),
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
            itemCount: paths.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => ImagePreview.show(context, paths[index]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    paths[index],
                    fit: BoxFit.cover,
                    cacheWidth: 300,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      child: const Icon(Icons.image_outlined, color: AppColors.gold),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
