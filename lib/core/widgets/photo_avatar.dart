import 'package:flutter/material.dart';

import '../assets/app_images.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'image_preview.dart';

/// Circular avatar backed by a bundled "people" photo, chosen from [name] so a
/// given person keeps the same face. Falls back to initials if the asset can't
/// load. Tapping it opens a full-screen preview (disable with [preview: false]).
///
/// The people photos are wide action shots, so the crop is biased slightly
/// upward to favour the golfer over the sky/turf.
class PhotoAvatar extends StatelessWidget {
  const PhotoAvatar({super.key, required this.name, this.radius = 20, this.preview = true});

  final String name;
  final double radius;
  final bool preview;

  String _initials() {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) return parts.isEmpty ? '?' : parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final avatar = SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Image.asset(
          AppImages.person(name),
          width: size,
          height: size,
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.35),
          cacheWidth: 240,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.gold,
            alignment: Alignment.center,
            child: Text(_initials(), style: AppTextStyles.bodyBold(AppColors.white)),
          ),
        ),
      ),
    );

    if (!preview) return avatar;
    return GestureDetector(
      onTap: () => ImagePreview.show(context, AppImages.person(name)),
      child: avatar,
    );
  }
}
