import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/roster_player.dart';
import 'tee_box_bar.dart';

/// A registered-but-unplaced player in the roster panel (§5.2), draggable into
/// any open group slot. The drag payload is the player's id.
class RosterPlayerChip extends StatelessWidget {
  const RosterPlayerChip({super.key, required this.player});

  final RosterPlayer player;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    final chip = _ChipBody(player: player, surface: surface, isDark: isDark);

    return LongPressDraggable<String>(
      data: player.id,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(opacity: 0.9, child: _ChipBody(player: player, surface: surface, isDark: isDark, elevated: true)),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: chip),
      child: chip,
    );
  }
}

class _ChipBody extends StatelessWidget {
  const _ChipBody({
    required this.player,
    required this.surface,
    required this.isDark,
    this.elevated = false,
  });

  final RosterPlayer player;
  final Color surface;
  final bool isDark;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      width: 172,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyLight),
        boxShadow: elevated
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 12, offset: const Offset(0, 4))]
            : null,
      ),
      child: Row(
        children: [
          TeeBoxBar(color: player.teeBoxColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(player.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodyBold(primaryText)),
                Row(
                  children: [
                    Text('Club HCP ${player.clubHandicap.toStringAsFixed(1)}', style: AppTextStyles.caption(secondaryText)),
                    if (player.isMainClub) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.verified, size: 12, color: AppColors.goldDark),
                      const SizedBox(width: 2),
                      Text('Main', style: AppTextStyles.caption(AppColors.goldDark)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.drag_indicator, size: 18, color: secondaryText),
        ],
      ),
    );
  }
}
