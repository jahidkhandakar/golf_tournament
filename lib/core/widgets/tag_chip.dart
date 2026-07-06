import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Small pill-shaped label used for format/format-like badges on cards
/// (e.g. "Scramble", "10 player max", "Not saved to handicap").
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, this.background, this.foreground});

  final String label;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Defaults must adapt to theme — a light-grey pill with grey text reads
    // fine in light mode but disappears against dark surfaces.
    final fg = foreground ?? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);
    final bg = background ?? (isDark ? AppColors.grey.withValues(alpha: 0.25) : AppColors.greyLight.withValues(alpha: 0.5));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: AppTextStyles.caption(fg)),
    );
  }
}
