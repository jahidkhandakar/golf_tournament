import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/play/play_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../challenge_action.dart';

/// Opened by tapping a Top 50 tile. Shows the player and the tournament
/// they're entered in, and walks the user through the prerequisites to
/// challenge them: join their club (if not already a member), then join the
/// tournament — only then does the Challenge button illuminate.
class ChallengePlayerPage extends StatelessWidget {
  const ChallengePlayerPage({super.key, required this.entry});

  final LeaderboardEntry entry;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) return parts.isEmpty ? '?' : parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final play = GetIt.instance<PlayController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final firstName = entry.playerName.split(' ').first;

    return Scaffold(
      appBar: AppBar(title: Text(entry.playerName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.gold,
                  child: Text(_initials(entry.playerName), style: AppTextStyles.heading1(AppColors.white)),
                ),
                const SizedBox(height: 12),
                Text(entry.playerName, style: AppTextStyles.heading2(primaryText)),
                const SizedBox(height: 4),
                Text(
                  'HCP ${entry.handicap.toStringAsFixed(1)} · ${entry.clubName}',
                  style: AppTextStyles.body(secondaryText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Playing in', style: AppTextStyles.heading3(primaryText)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.tournamentName, style: AppTextStyles.bodyBold(primaryText)),
                  const SizedBox(height: 6),
                  _IconLine(icon: Icons.golf_course_outlined, text: entry.courseName, color: secondaryText),
                  const SizedBox(height: 4),
                  _IconLine(icon: Icons.schedule, text: 'Tee time ${entry.teeTime}', color: secondaryText),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // The action area reacts to both membership sets so joining a club
          // or tournament updates it live.
          ValueListenableBuilder<Set<String>>(
            valueListenable: play.joinedClubs,
            builder: (context, clubs, _) {
              return ValueListenableBuilder<Set<String>>(
                valueListenable: play.joinedTournaments,
                builder: (context, tournaments, _) {
                  final inClub = clubs.contains(entry.clubName);
                  final inTournament = tournaments
                      .contains(PlayController.tournamentKey(entry.tournamentId, entry.courseName));

                  if (inTournament) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "You're both in ${entry.tournamentName} at ${entry.courseName} — "
                                "you can challenge $firstName.",
                                style: AppTextStyles.caption(secondaryText),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => sendChallenge(context, entry),
                            icon: const Icon(Icons.sports_golf),
                            label: Text('Challenge $firstName'),
                          ),
                        ),
                      ],
                    );
                  }

                  if (!inClub) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'You need to join ${entry.clubName} before you can enter this tournament.',
                          style: AppTextStyles.body(secondaryText),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => play.joinClub(entry.clubName),
                          child: Text('Join ${entry.clubName}'),
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "You're in ${entry.clubName}. Join ${entry.tournamentName} at ${entry.courseName} "
                        "to challenge $firstName.",
                        style: AppTextStyles.body(secondaryText),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => play.joinTournament(entry.tournamentId, entry.courseName),
                        child: const Text('Join Tournament'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: AppTextStyles.caption(color))),
      ],
    );
  }
}
