import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/leaderboard_entry.dart';

const _gold = Color(0xFFFFD700);
const _silver = Color(0xFFC0C0C0);
const _bronze = Color(0xFFCD7F32);

class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({super.key, required this.entry, required this.onChallenge});

  final LeaderboardEntry entry;
  final VoidCallback onChallenge;

  Color? _medalColor() {
    switch (entry.rank) {
      case 1:
        return _gold;
      case 2:
        return _silver;
      case 3:
        return _bronze;
      default:
        return null;
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) return parts.isEmpty ? '?' : parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final medalColor = _medalColor();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: medalColor != null
                  ? Icon(Icons.emoji_events, color: medalColor, size: 24)
                  : Text(
                      '${entry.rank}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading3(AppColors.grey),
                    ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: AppColors.gold.withValues(alpha: 0.2),
              child: Text(_initials(entry.playerName), style: AppTextStyles.bodyBold(AppColors.goldDark)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.playerName, style: AppTextStyles.bodyBold(primaryText)),
                  Text(
                    'HCP ${entry.handicap.toStringAsFixed(1)} · ${entry.roundsPlayed} rounds',
                    style: AppTextStyles.caption(secondaryText),
                  ),
                ],
              ),
            ),
            OutlinedButton(onPressed: onChallenge, child: const Text('Challenge')),
          ],
        ),
      ),
    );
  }
}
