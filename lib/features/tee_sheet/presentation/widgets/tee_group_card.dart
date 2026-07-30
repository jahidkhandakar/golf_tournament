import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/player_slot.dart';
import '../../domain/entities/tee_group.dart';
import 'tee_box_bar.dart';

/// One tee-time group in the builder: header (Group N · tee time) plus its four
/// slots as drop targets. Dragging a roster chip onto a slot calls [onAssign].
class TeeGroupCard extends StatelessWidget {
  const TeeGroupCard({
    super.key,
    required this.group,
    required this.onAssign,
    required this.onUnassign,
    required this.onAddGuest,
    required this.onEditTime,
  });

  final TeeGroup group;
  final void Function(int groupNumber, SlotPosition position, String playerId) onAssign;
  final void Function(int groupNumber, SlotPosition position) onUnassign;
  final void Function(int groupNumber, SlotPosition position) onAddGuest;
  final void Function(int groupNumber) onEditTime;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => onEditTime(group.groupNumber),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(group.teeTime, style: AppTextStyles.bodyBold(AppColors.goldDark)),
                        const SizedBox(width: 4),
                        const Icon(Icons.edit, size: 12, color: AppColors.goldDark),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('Group ${group.groupNumber}', style: AppTextStyles.bodyBold(primaryText)),
                const Spacer(),
                if (group.openCount > 0)
                  Text('${group.openCount} open', style: AppTextStyles.caption(secondaryText)),
              ],
            ),
            const SizedBox(height: 8),
            ...group.slots.map(
              (slot) => _SlotTile(
                slot: slot,
                groupId: group.slotId(slot.position),
                onAssign: (playerId) => onAssign(group.groupNumber, slot.position, playerId),
                onUnassign: () => onUnassign(group.groupNumber, slot.position),
                onAddGuest: () => onAddGuest(group.groupNumber, slot.position),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.slot,
    required this.groupId,
    required this.onAssign,
    required this.onUnassign,
    required this.onAddGuest,
  });

  final PlayerSlot slot;
  final String groupId;
  final void Function(String playerId) onAssign;
  final VoidCallback onUnassign;
  final VoidCallback onAddGuest;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => slot.isOpen,
      onAcceptWithDetails: (details) => onAssign(details.data),
      builder: (context, candidate, rejected) {
        final hovering = candidate.isNotEmpty;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: hovering ? AppColors.gold.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hovering
                  ? AppColors.goldDark
                  : slot.isOpen
                      ? AppColors.greyLight
                      : AppColors.greyLight.withValues(alpha: 0.6),
              style: slot.isOpen ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 34,
                child: Text(groupId, style: AppTextStyles.caption(secondaryText)),
              ),
              const SizedBox(width: 4),
              if (slot.isOpen) ..._openSlot(secondaryText) else ..._filledSlot(context, primaryText, secondaryText),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _openSlot(Color secondaryText) {
    return [
      Icon(Icons.add_circle_outline, size: 18, color: secondaryText),
      const SizedBox(width: 8),
      Text('OPEN — drop a player here', style: AppTextStyles.caption(secondaryText)),
      const Spacer(),
      TextButton(
        onPressed: onAddGuest,
        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: Size.zero),
        child: Text('+ Guest', style: AppTextStyles.caption(AppColors.goldDark)),
      ),
    ];
  }

  List<Widget> _filledSlot(BuildContext context, Color primaryText, Color secondaryText) {
    final player = slot.player;
    return [
      if (slot.isGuest)
        Container(width: 4, height: 36, decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(4)))
      else
        TeeBoxBar(color: player!.teeBoxColor),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(slot.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodyBold(primaryText)),
                ),
                if (slot.hasChallengeBadge) ...[
                  const SizedBox(width: 6),
                  _ChallengeBadge(),
                ],
              ],
            ),
            if (slot.isGuest)
              Text('Guest · course backfill', style: AppTextStyles.caption(secondaryText))
            else
              Text('Club HCP ${player!.clubHandicap.toStringAsFixed(1)}', style: AppTextStyles.caption(secondaryText)),
          ],
        ),
      ),
      IconButton(
        onPressed: onUnassign,
        icon: Icon(Icons.close, size: 18, color: secondaryText),
        tooltip: 'Clear slot',
        visualDensity: VisualDensity.compact,
      ),
    ];
  }
}

/// The gold Challenge badge shown when a slot's player is in a confirmed
/// challenge pair (§5.3).
class _ChallengeBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sports_golf, size: 11, color: AppColors.goldDark),
          const SizedBox(width: 3),
          Text('Challenge', style: AppTextStyles.caption(AppColors.goldDark)),
        ],
      ),
    );
  }
}
