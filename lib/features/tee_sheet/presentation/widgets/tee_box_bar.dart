import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/tee_box_color.dart';

/// The colored bar drawn on a player slot to show their tee box (§5.3). These
/// are the literal golf tee colors, not the app palette — White gets a border
/// so it reads on a light surface.
class TeeBoxBar extends StatelessWidget {
  const TeeBoxBar({super.key, required this.color, this.width = 4, this.height = 36});

  final TeeBoxColor color;
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
    final fill = swatch(color);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(width),
        border: color == TeeBoxColor.white ? Border.all(color: AppColors.greyLight) : null,
      ),
    );
  }
}
