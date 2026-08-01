import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/tee_box_color.dart';

/// The colored bar drawn on a player slot to show their tee box. These are the
/// literal golf tee colors. Per the build, every color bar carries a gold
/// border; the Gold bar itself uses a thin dark border so its edge stays
/// visible. A null [color] means the player self selects at the course (fewer
/// than 3 scored rounds) and renders as a gray outline bar.
class TeeBoxBar extends StatelessWidget {
  const TeeBoxBar({super.key, required this.color, this.width = 4, this.height = 36});

  final TeeBoxColor? color;
  final double width;
  final double height;

  static Color swatch(TeeBoxColor color) {
    switch (color) {
      case TeeBoxColor.black:
        return const Color(0xFF1A1A1A);
      case TeeBoxColor.blue:
        return const Color(0xFF1E5AA8);
      case TeeBoxColor.white:
        return const Color(0xFFF5F5F5);
      case TeeBoxColor.gold:
        return AppColors.gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = color;
    if (c == null) {
      // Self select: no established handicap yet.
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(width),
          border: Border.all(color: AppColors.greyLight),
        ),
      );
    }
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: swatch(c),
        borderRadius: BorderRadius.circular(width),
        border: Border.all(
          color: c == TeeBoxColor.gold ? const Color(0xFF6B5A17) : AppColors.gold,
          width: 1,
        ),
      ),
    );
  }
}
