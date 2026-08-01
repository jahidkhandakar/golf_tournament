import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/location/location_state.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/photo_avatar.dart';
import '../../../profile/domain/repositories/user_profile_repository.dart';
import '../../../tournament/domain/entities/challenge_approval.dart';
import '../../../tournament/domain/repositories/challenge_approval_repository.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../challenge_action.dart';
import '../top50_ladder_controller.dart';
import '../widgets/leaderboard_row.dart';
import '../widgets/rank_medal.dart';

/// Rendered as the Top 50 tab's body inside [MainShell]. A position-based
/// challenge ladder: beat a player ranked above you and you take their spot.
/// Players are shown within the user's current search radius (60 mi, or 120 mi
/// for rural villages). The Challenge button only illuminates once you're both
/// in the same tournament + course.
class Top50Page extends StatefulWidget {
  const Top50Page({super.key});

  @override
  State<Top50Page> createState() => _Top50PageState();
}

class _Top50PageState extends State<Top50Page> {
  final Top50LadderController _ladder = GetIt.instance<Top50LadderController>();
  final ChallengeApprovalRepository _challenges = GetIt.instance<ChallengeApprovalRepository>();

  String _me = '';
  List<ChallengeApproval> _incoming = [];

  @override
  void initState() {
    super.initState();
    _ladder.ensureLoaded();
    _loadIncoming();
  }

  Future<void> _loadIncoming() async {
    final me = _me.isNotEmpty ? _me : (await GetIt.instance<UserProfileRepository>().getCurrentUser()).name;
    final incoming = await _challenges.incomingFor(me);
    if (!mounted) return;
    setState(() {
      _me = me;
      _incoming = incoming;
    });
  }

  Future<void> _decline(ChallengeApproval c) async {
    // Declining while co-registered drops the decliner on the ladder (§3).
    _ladder.recordDecline(_me);
    await _challenges.decline(c.id);
    await _loadIncoming();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = GetIt.instance<LocationState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return ValueListenableBuilder<List<LeaderboardEntry>>(
      valueListenable: _ladder.ladder,
      builder: (context, allEntries, _) {
        if (allEntries.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ValueListenableBuilder<int>(
          valueListenable: locationState.radiusMiles,
          builder: (context, radius, _) {
            final entries = allEntries.where((e) => e.distanceMiles <= radius).toList()
              ..sort((a, b) => a.position.compareTo(b.position));

            return Column(
              children: [
                for (final c in _incoming)
                  _IncomingChallengeCard(challenge: c, onDecline: () => _decline(c)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events_outlined, size: 16, color: secondaryText),
                      const SizedBox(width: 4),
                      Text('Challenge ladder · within $radius mi', style: AppTextStyles.caption(secondaryText)),
                    ],
                  ),
                ),
                Expanded(
                  child: entries.isEmpty
                      ? Center(
                          child: Text('No ranked players nearby', style: AppTextStyles.body(secondaryText)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 12),
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            if (entry.isCurrentUser) {
                              return _CurrentUserRow(entry: entry);
                            }
                            return LeaderboardRow(
                              rank: entry.position,
                              entry: entry,
                              onTap: () => context.push(AppRoutes.challengePlayer(entry.playerName), extra: entry),
                              onChallenge: () => sendChallenge(context, entry),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// A challenge aimed at the logged-in user. They can decline it — which drops
/// them on the ladder (§3); otherwise it plays out and resolves at the scorecard.
class _IncomingChallengeCard extends StatelessWidget {
  const _IncomingChallengeCard({required this.challenge, required this.onDecline});

  final ChallengeApproval challenge;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      color: AppColors.gold.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
        child: Row(
          children: [
            const Icon(Icons.sports_golf, color: AppColors.goldDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${challenge.challengerName} challenged you', style: AppTextStyles.bodyBold(primaryText)),
                  Text('Play it out, or decline (drops you on the ladder).',
                      style: AppTextStyles.caption(secondaryText)),
                ],
              ),
            ),
            TextButton(
              onPressed: onDecline,
              child: Text('Decline', style: AppTextStyles.bodyBold(AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}

/// The logged-in user's own row on the ladder — highlighted, no challenge button.
class _CurrentUserRow extends StatelessWidget {
  const _CurrentUserRow({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: AppColors.gold.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            RankMedal(rank: entry.position),
            const SizedBox(width: 10),
            PhotoAvatar(name: entry.playerName, radius: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${entry.playerName} (You)', style: AppTextStyles.bodyBold(primaryText)),
                  Text(
                    'Your ladder position · #${entry.position}',
                    style: AppTextStyles.caption(secondaryText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
