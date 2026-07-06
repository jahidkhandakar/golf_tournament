import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

typedef _ClubResult = ({
  String eventName,
  String date,
  String format,
  String winnerName,
  String winningScore,
});

const _results = <_ClubResult>[
  (
    eventName: 'Spring Club Championship',
    date: 'Jun 21',
    format: 'Stroke Play',
    winnerName: 'Erin Walsh',
    winningScore: '-4',
  ),
  (
    eventName: 'Member-Guest Scramble',
    date: 'Jun 7',
    format: 'Scramble',
    winnerName: 'Marcus Thompson & guest',
    winningScore: '-9',
  ),
  (
    eventName: 'Monthly Medal',
    date: 'May 24',
    format: 'Stroke Play',
    winnerName: 'Priya Kapoor',
    winningScore: '+1',
  ),
];

class ResultsTab extends StatelessWidget {
  const ResultsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.gold,
              child: Icon(Icons.emoji_events, color: AppColors.white),
            ),
            title: Text(result.eventName, style: AppTextStyles.bodyBold(primaryText)),
            subtitle: Text(
              '${result.date} · ${result.format}\nWinner: ${result.winnerName}',
              style: AppTextStyles.caption(secondaryText),
            ),
            isThreeLine: true,
            trailing: Text(result.winningScore, style: AppTextStyles.heading3(AppColors.goldDark)),
          ),
        );
      },
    );
  }
}
