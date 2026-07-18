import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/club_member.dart';

typedef _ResultTemplate = ({String eventName, String date, String format, String score});

const _templates = <_ResultTemplate>[
  (eventName: 'Spring Club Championship', date: 'Jun 21', format: 'Stroke Play', score: '-4'),
  (eventName: 'Member-Guest Scramble', date: 'Jun 7', format: 'Scramble', score: '-9'),
  (eventName: 'Monthly Medal', date: 'May 24', format: 'Stroke Play', score: '+1'),
  (eventName: 'Twilight Cup', date: 'May 10', format: 'Best Ball', score: '-2'),
];

/// A club's recent results — winners are drawn from the club's own members so
/// switching clubs shows that club's events and champions.
class ResultsTab extends StatelessWidget {
  const ResultsTab({super.key, required this.members});

  final List<ClubMember> members;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    if (members.isEmpty) {
      return Center(child: Text('No results yet', style: AppTextStyles.body(secondaryText)));
    }

    // One result per template, each won by a different club member.
    final count = members.length < _templates.length ? members.length : _templates.length;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: count,
      itemBuilder: (context, index) {
        final template = _templates[index];
        final winner = members[index % members.length];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.gold,
              child: Icon(Icons.emoji_events, color: AppColors.white),
            ),
            title: Text(template.eventName, style: AppTextStyles.bodyBold(primaryText)),
            subtitle: Text(
              '${template.date} · ${template.format}\nWinner: ${winner.name}',
              style: AppTextStyles.caption(secondaryText),
            ),
            isThreeLine: true,
            trailing: Text(template.score, style: AppTextStyles.heading3(AppColors.goldDark)),
          ),
        );
      },
    );
  }
}
