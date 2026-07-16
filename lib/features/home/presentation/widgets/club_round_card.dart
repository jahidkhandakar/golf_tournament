import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/tag_chip.dart';
import '../../domain/entities/club_round.dart';

class ClubRoundCard extends StatelessWidget {
  const ClubRoundCard({
    super.key,
    required this.clubRound,
    required this.onRequestToPlay,
    required this.onJoinClub,
  });

  final ClubRound clubRound;
  final VoidCallback onRequestToPlay;
  final VoidCallback onJoinClub;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(clubRound.clubName, style: AppTextStyles.heading3(primaryText)),
                ),
                TagChip(
                  label: clubRound.format,
                  background: AppColors.gold.withValues(alpha: 0.16),
                  foreground: AppColors.goldDark,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              text: '${formatShortDate(clubRound.date)} · ${clubRound.teeTime}',
              color: secondaryText,
            ),
            const SizedBox(height: 4),
            _InfoRow(icon: Icons.golf_course_outlined, text: clubRound.courseName, color: secondaryText),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: _InfoRow(
                    icon: Icons.groups_outlined,
                    text: '${clubRound.currentPlayers}/${clubRound.maxPlayers} players',
                    color: secondaryText,
                  ),
                ),
                _InfoRow(
                  icon: Icons.near_me_outlined,
                  text: '${clubRound.distanceMiles.toStringAsFixed(1)} mi',
                  color: secondaryText,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRequestToPlay,
                    child: const Text('Request to Play'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onJoinClub,
                    child: const Text('Join Club'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Flexible(child: Text(text, style: AppTextStyles.caption(color))),
      ],
    );
  }
}
