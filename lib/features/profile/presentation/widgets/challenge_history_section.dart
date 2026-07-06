import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/challenge.dart';

class ChallengeHistorySection extends StatelessWidget {
  const ChallengeHistorySection({super.key, required this.challenges});

  final List<Challenge> challenges;

  Color _statusColor(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.won:
        return AppColors.success;
      case ChallengeStatus.lost:
        return AppColors.error;
      case ChallengeStatus.pending:
        return AppColors.grey;
    }
  }

  String _statusLabel(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.won:
        return 'Won';
      case ChallengeStatus.lost:
        return 'Lost';
      case ChallengeStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    if (challenges.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text('No challenges yet.', style: AppTextStyles.body(secondaryText)),
      );
    }

    return Column(
      children: [
        for (final challenge in challenges)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _statusColor(challenge.status).withValues(alpha: 0.15),
                child: Icon(Icons.sports_golf, color: _statusColor(challenge.status)),
              ),
              title: Text('vs ${challenge.opponentName}', style: AppTextStyles.bodyBold(primaryText)),
              subtitle: Text(formatShortDate(challenge.date), style: AppTextStyles.caption(secondaryText)),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _statusLabel(challenge.status),
                    style: AppTextStyles.bodyBold(_statusColor(challenge.status)),
                  ),
                  if (challenge.resultSummary != null)
                    Text(challenge.resultSummary!, style: AppTextStyles.caption(secondaryText)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
