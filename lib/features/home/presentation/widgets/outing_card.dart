import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/tag_chip.dart';
import '../../domain/entities/outing.dart';

/// Visually lighter than [ClubRoundCard] — flat, no gold accent — since outings
/// are casual, player-organized rounds rather than club tournaments.
class OutingCard extends StatelessWidget {
  const OutingCard({super.key, required this.outing, required this.onJoin});

  final Outing outing;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.grey.withValues(alpha: 0.4) : AppColors.greyLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(outing.title, style: AppTextStyles.bodyBold(primaryText)),
            const SizedBox(height: 2),
            Text('Hosted by ${outing.hostName}', style: AppTextStyles.caption(secondaryText)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                TagChip(label: outing.format),
                TagChip(label: '${formatShortDate(outing.dateTime)} · ${_formatTime(outing.dateTime)}'),
                const TagChip(label: '10 player max'),
                const TagChip(label: 'Not saved to handicap'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.groups_outlined, size: 15, color: secondaryText),
                const SizedBox(width: 4),
                Text(
                  '${outing.currentPlayers}/${outing.maxPlayers} players',
                  style: AppTextStyles.caption(secondaryText),
                ),
                const Spacer(),
                Icon(Icons.near_me_outlined, size: 15, color: secondaryText),
                const SizedBox(width: 4),
                Text('${outing.distanceMiles.toStringAsFixed(1)} mi', style: AppTextStyles.caption(secondaryText)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: onJoin, child: const Text('Join')),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
