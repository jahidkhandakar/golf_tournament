import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../core/play/play_controller.dart';
import '../../../core/router/app_routes.dart';
import '../../profile/domain/repositories/user_profile_repository.dart';
import '../../tournament/domain/entities/tournament.dart';
import '../../tournament/domain/repositories/challenge_approval_repository.dart';
import '../../tournament/domain/repositories/tournament_repository.dart';
import '../domain/entities/leaderboard_entry.dart';
import 'top50_ladder_controller.dart';

/// Sends a challenge to [entry]'s player. The path depends on the rules:
///   - roster locked (48h) → frozen, nothing happens (§7)
///   - same-club, 8+ tournament → submitted for club-admin approval (§3); it
///     only counts once approved
///   - otherwise → resolved immediately (mock): locked into a shared tee time
///     and the ladder moves
/// Only call once both players are in the same tournament + course.
Future<void> sendChallenge(BuildContext context, LeaderboardEntry entry) async {
  final play = GetIt.instance<PlayController>();
  final tournament = await GetIt.instance<TournamentRepository>().getTournament(entry.tournamentId);
  if (!context.mounted) return;

  // The 48h roster lock also freezes new challenges (§7).
  if (tournament != null && tournament.isRosterLocked) {
    await _notice(context, 'Challenges frozen',
        'This tournament locked 48 hours before tee off — no new challenges can be sent.');
    return;
  }

  // Same-club challenges in an 8+ tournament need a Club Creator / sub-admin to
  // approve them before they count toward the Club Leaderboard or Top 50 (§3).
  final sameClub = play.isInClub(entry.clubName);
  final eightPlus = (tournament?.registeredPlayers ?? 0) >= Tournament.minPlayers;
  if (sameClub && eightPlus) {
    final me = await GetIt.instance<UserProfileRepository>().getCurrentUser();
    await GetIt.instance<ChallengeApprovalRepository>().submit(
      tournamentId: entry.tournamentId,
      clubName: entry.clubName,
      challengerName: me.name,
      opponentName: entry.playerName,
    );
    if (!context.mounted) return;
    await _notice(context, 'Sent for approval',
        'Your challenge to ${entry.playerName} was sent to the ${entry.clubName} admins. It counts once approved.');
    return;
  }

  // Otherwise resolve immediately (mock): lock the tee time and move the ladder.
  play.lockInChallenge(
    TeeSheetEntry(
      opponentName: entry.playerName,
      tournamentName: entry.tournamentName,
      courseName: entry.courseName,
      teeTime: entry.teeTime,
      date: 'This weekend',
    ),
  );
  GetIt.instance<Top50LadderController>().recordUserWin(entry.playerName);

  if (!context.mounted) return;
  final firstName = entry.playerName.split(' ').first;
  final viewTeeSheet = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Challenge Accepted'),
      content: Text(
        "You're locked in with $firstName at ${entry.teeTime} for ${entry.tournamentName}. "
        "It's been added to your tee sheet.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('View Tee Sheet'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Done'),
        ),
      ],
    ),
  );

  if (viewTeeSheet == true && context.mounted) {
    context.push(AppRoutes.teeSheet);
  }
}

Future<void> _notice(BuildContext context, String title, String body) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('OK')),
      ],
    ),
  );
}
