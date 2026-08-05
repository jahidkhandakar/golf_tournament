import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/play/play_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/photo_avatar.dart';
import '../../domain/entities/leaderboard_entry.dart';
import 'rank_medal.dart';

class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({
    super.key,
    required this.rank,
    required this.entry,
    required this.onTap,
    required this.onChallenge,
  });

  /// Display rank within the current (location-filtered) leaderboard.
  final int rank;
  final LeaderboardEntry entry;

  /// Opens the player detail / challenge screen.
  final VoidCallback onTap;

  /// Fires the challenge — only reachable once both players share a
  /// tournament (the button is otherwise replaced by a chevron).
  final VoidCallback onChallenge;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              RankMedal(rank: rank),
              const SizedBox(width: 10),
              PhotoAvatar(name: entry.playerName, radius: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.playerName, style: AppTextStyles.bodyBold(primaryText)),
                    Text('${entry.distanceMiles.toStringAsFixed(0)} mi',
                        style: AppTextStyles.caption(secondaryText)),
                  ],
                ),
              ),
              // Challenge only illuminates once you've joined the player's
              // tournament; otherwise a chevron hints to tap through.
              ValueListenableBuilder<Set<String>>(
                valueListenable: GetIt.instance<PlayController>().joinedTournaments,
                builder: (context, tournaments, _) {
                  final canChallenge =
                      tournaments.contains(PlayController.tournamentKey(entry.tournamentId, entry.courseName));
                  if (canChallenge) {
                    return ElevatedButton(onPressed: onChallenge, child: const Text('Challenge'));
                  }
                  return Icon(Icons.chevron_right, color: secondaryText);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
