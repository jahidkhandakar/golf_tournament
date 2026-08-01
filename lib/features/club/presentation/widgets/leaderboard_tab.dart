import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/club/club_leaderboard_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/tag_chip.dart';
import '../../../profile/domain/repositories/user_profile_repository.dart';
import '../../../top50/presentation/widgets/rank_medal.dart';
import '../../domain/entities/club_member.dart';

/// Number of ranked members at which the leaderboard is considered live.
const int _goesLiveAt = 8;

/// Club-scoped leaderboard: ranks this club's members by their **stored**
/// position (seeded from handicap order at opt-in, then moved only by
/// challenges) — never re-sorted by handicap. Opt-in is off by default; the
/// logged-in user joins or leaves from here.
class LeaderboardTab extends StatefulWidget {
  const LeaderboardTab({super.key, required this.members, required this.clubName});

  final List<ClubMember> members;
  final String clubName;

  @override
  State<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<LeaderboardTab> {
  final ClubLeaderboardState _state = GetIt.instance<ClubLeaderboardState>();
  double? _userHandicap;

  @override
  void initState() {
    super.initState();
    GetIt.instance<UserProfileRepository>().getCurrentUser().then((u) {
      if (mounted) setState(() => _userHandicap = u.clubHandicap);
    });
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) return parts.isEmpty ? '?' : parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  void _optIn(List<ClubMember> ranked) {
    final handicap = _userHandicap;
    if (handicap == null) return;
    // Seed the user's position from handicap order: one below every ranked
    // member with a better (lower) handicap.
    final betterThanUser = ranked.where((m) => m.clubHandicap < handicap).length;
    _state.optIn(widget.clubName, seededPosition: betterThanUser + 1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final ranked = [
      for (final m in widget.members)
        if (m.isRanked) m,
    ]..sort((a, b) => a.leaderboardPosition!.compareTo(b.leaderboardPosition!));

    return ValueListenableBuilder<Map<String, int>>(
      valueListenable: _state.positions,
      builder: (context, _, __) {
        final optedIn = _state.isOptedIn(widget.clubName);
        final userPosition = _state.positionIn(widget.clubName);

        // Combined display rows: ranked members plus the user's own row.
        final rows = <_Row>[
          for (final m in ranked)
            _Row(name: m.name, handicap: m.clubHandicap, position: m.leaderboardPosition!, isAdmin: m.isAdmin),
          if (optedIn && userPosition != null)
            _Row(name: 'You', handicap: _userHandicap ?? 0, position: userPosition, isUser: true),
        ]..sort((a, b) => a.position.compareTo(b.position));

        final liveCount = rows.length;

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _OptInCard(
              optedIn: optedIn,
              canOptIn: _userHandicap != null,
              onOptIn: () => _optIn(ranked),
              onOptOut: () => _state.optOut(widget.clubName),
            ),
            if (liveCount < _goesLiveAt)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  'Leaderboard goes live at $_goesLiveAt ranked members · $liveCount now.',
                  style: AppTextStyles.caption(secondaryText),
                ),
              ),
            for (var i = 0; i < rows.length; i++) _rowCard(rows[i], i + 1, primaryText, secondaryText),
          ],
        );
      },
    );
  }

  Widget _rowCard(_Row row, int rank, Color primaryText, Color secondaryText) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: row.isUser ? AppColors.gold.withValues(alpha: 0.12) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            RankMedal(rank: rank),
            const SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: AppColors.gold.withValues(alpha: 0.2),
              child: Text(row.isUser ? 'You' : _initials(row.name),
                  style: AppTextStyles.caption(AppColors.goldDark)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(row.isUser ? 'You' : row.name, style: AppTextStyles.bodyBold(primaryText)),
                  Text('Club HCP ${row.handicap.toStringAsFixed(1)}', style: AppTextStyles.caption(secondaryText)),
                ],
              ),
            ),
            if (row.isAdmin)
              TagChip(
                label: 'Admin',
                background: AppColors.gold.withValues(alpha: 0.16),
                foreground: AppColors.goldDark,
              ),
          ],
        ),
      ),
    );
  }
}

class _Row {
  const _Row({
    required this.name,
    required this.handicap,
    required this.position,
    this.isAdmin = false,
    this.isUser = false,
  });

  final String name;
  final double handicap;
  final int position;
  final bool isAdmin;
  final bool isUser;
}

class _OptInCard extends StatelessWidget {
  const _OptInCard({
    required this.optedIn,
    required this.canOptIn,
    required this.onOptIn,
    required this.onOptOut,
  });

  final bool optedIn;
  final bool canOptIn;
  final VoidCallback onOptIn;
  final VoidCallback onOptOut;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(optedIn ? "You're on the leaderboard" : 'Join the club leaderboard',
                      style: AppTextStyles.bodyBold(primaryText)),
                  Text(
                    optedIn
                        ? 'Your position moves only through challenges.'
                        : 'Opt in to be ranked. Needs an established handicap (3+ rounds).',
                    style: AppTextStyles.caption(secondaryText),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            optedIn
                ? OutlinedButton(onPressed: onOptOut, child: const Text('Opt out'))
                : ElevatedButton(onPressed: canOptIn ? onOptIn : null, child: const Text('Opt in')),
          ],
        ),
      ),
    );
  }
}
