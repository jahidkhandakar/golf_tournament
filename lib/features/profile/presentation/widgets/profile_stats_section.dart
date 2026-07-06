import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/round.dart';

/// Small stats derived client-side from the round history — no separate
/// stats endpoint needed for a mock this size.
class ProfileStatsSection extends StatelessWidget {
  const ProfileStatsSection({super.key, required this.rounds});

  final List<Round> rounds;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final roundsPlayed = rounds.length;
    final avgToPar = roundsPlayed == 0
        ? 0
        : (rounds.map((r) => r.toPar).reduce((a, b) => a + b) / roundsPlayed);
    final bestScore = roundsPlayed == 0 ? 0 : rounds.map((r) => r.score).reduce((a, b) => a < b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatTile(label: 'Rounds', value: '$roundsPlayed', primaryText: primaryText, secondaryText: secondaryText),
          _StatTile(
            label: 'Avg to Par',
            value: roundsPlayed == 0 ? '—' : (avgToPar >= 0 ? '+${avgToPar.toStringAsFixed(1)}' : avgToPar.toStringAsFixed(1)),
            primaryText: primaryText,
            secondaryText: secondaryText,
          ),
          _StatTile(
            label: 'Best Round',
            value: roundsPlayed == 0 ? '—' : '$bestScore',
            primaryText: primaryText,
            secondaryText: secondaryText,
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.primaryText,
    required this.secondaryText,
  });

  final String label;
  final String value;
  final Color primaryText;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Text(value, style: AppTextStyles.heading2(AppColors.goldDark)),
              const SizedBox(height: 2),
              Text(label, style: AppTextStyles.caption(secondaryText)),
            ],
          ),
        ),
      ),
    );
  }
}
