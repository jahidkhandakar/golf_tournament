import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/tag_chip.dart';
import '../../../top50/presentation/widgets/rank_medal.dart';
import '../../domain/entities/club_member.dart';

/// Club-scoped leaderboard: ranks this club's members by handicap
/// (lower is better). Separate from the app-wide Top 50 tab.
class LeaderboardTab extends StatelessWidget {
  const LeaderboardTab({super.key, required this.members});

  final List<ClubMember> members;

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

    final ranked = [...members]..sort((a, b) => a.handicap.compareTo(b.handicap));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: ranked.length,
      itemBuilder: (context, index) {
        final member = ranked[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                RankMedal(rank: index + 1),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                  child: Text(_initials(member.name), style: AppTextStyles.bodyBold(AppColors.goldDark)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.name, style: AppTextStyles.bodyBold(primaryText)),
                      Text('HCP ${member.handicap.toStringAsFixed(1)}', style: AppTextStyles.caption(secondaryText)),
                    ],
                  ),
                ),
                if (member.isAdmin)
                  TagChip(
                    label: 'Admin',
                    background: AppColors.gold.withValues(alpha: 0.16),
                    foreground: AppColors.goldDark,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
