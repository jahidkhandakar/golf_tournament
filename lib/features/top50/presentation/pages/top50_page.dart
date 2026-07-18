import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/location/location_state.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../challenge_action.dart';
import '../widgets/leaderboard_row.dart';

/// Rendered as the Top 50 tab's body inside [MainShell]. Players are ranked
/// among those within the user's current search radius (60 mi, or 120 mi for
/// rural villages). Tap a tile to view a player and join their tournament;
/// the Challenge button only illuminates once you're both in it.
class Top50Page extends StatefulWidget {
  const Top50Page({super.key});

  @override
  State<Top50Page> createState() => _Top50PageState();
}

class _Top50PageState extends State<Top50Page> {
  late final Future<List<LeaderboardEntry>> _future =
      GetIt.instance<LeaderboardRepository>().getLeaderboard();

  @override
  Widget build(BuildContext context) {
    final locationState = GetIt.instance<LocationState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return FutureBuilder<List<LeaderboardEntry>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final allEntries = snapshot.data!;

        return ValueListenableBuilder<int>(
          valueListenable: locationState.radiusMiles,
          builder: (context, radius, _) {
            final entries = allEntries.where((e) => e.distanceMiles <= radius).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events_outlined, size: 16, color: secondaryText),
                      const SizedBox(width: 4),
                      Text('Top players within $radius mi', style: AppTextStyles.caption(secondaryText)),
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
                            return LeaderboardRow(
                              rank: index + 1,
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
