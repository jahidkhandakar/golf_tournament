import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/club_member.dart';

/// Full results view for a past club event — opened by tapping a Results card.
/// Shows every player's final score.
///
/// Mock note: scores are derived deterministically from the club roster so the
/// board is stable across rebuilds. The real implementation loads the event's
/// submitted scorecards.
class EventResultsPage extends StatelessWidget {
  const EventResultsPage({
    super.key,
    required this.eventName,
    required this.date,
    required this.format,
    required this.members,
  });

  final String eventName;
  final String date;
  final String format;
  final List<ClubMember> members;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    // Deterministic mock "to par" per member, then ranked best-first.
    final scored = <({ClubMember member, int toPar})>[
      for (var i = 0; i < members.length; i++)
        (member: members[i], toPar: ((i * 37 + 11) % 15) - 6),
    ]..sort((a, b) => a.toPar.compareTo(b.toPar));

    String fmt(int toPar) => toPar == 0 ? 'E' : (toPar > 0 ? '+$toPar' : '$toPar');

    return Scaffold(
      appBar: AppBar(title: Text(eventName)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
            child: Text('$date · $format', style: AppTextStyles.body(secondaryText)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: Text('Final scores', style: AppTextStyles.heading3(primaryText)),
          ),
          Expanded(
            child: scored.isEmpty
                ? Center(
                    child: Text('No scores recorded', style: AppTextStyles.body(secondaryText)))
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: scored.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final row = scored[index];
                      final position = index + 1;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              position == 1 ? AppColors.gold : AppColors.grey.withValues(alpha: 0.2),
                          child: position == 1
                              ? const Icon(Icons.emoji_events, color: AppColors.white, size: 20)
                              : Text('$position', style: AppTextStyles.bodyBold(primaryText)),
                        ),
                        title: Text(row.member.shownName, style: AppTextStyles.bodyBold(primaryText)),
                        subtitle: Text(
                          'Handicap ${row.member.clubHandicap.toStringAsFixed(0)}',
                          style: AppTextStyles.caption(secondaryText),
                        ),
                        trailing: Text(fmt(row.toPar),
                            style: AppTextStyles.heading3(AppColors.goldDark)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
