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

/// Sends a challenge to [entry]'s player. Sending is not winning: it records a
/// challenge and locks both players into a shared tee time, with NO ladder
/// movement. The result is decided when the round's scorecard is submitted (§6).
///
///   - roster locked (48h)        → frozen, nothing happens (§7)
///   - same-club, 8+ tournament   → recorded pending club-admin approval (§3)
///   - otherwise                  → recorded as a confirmed challenge
///
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

  final me = await GetIt.instance<UserProfileRepository>().getCurrentUser();
  if (!context.mounted) return;

  // Same-club challenges in an 8+ tournament need a Club Creator / sub-admin to
  // approve them before they count (§3); everything else is confirmed on send.
  final sameClub = play.isInClub(entry.clubName);
  final eightPlus = (tournament?.registeredPlayers ?? 0) >= Tournament.minPlayers;
  final needsApproval = sameClub && eightPlus;

  await GetIt.instance<ChallengeApprovalRepository>().submit(
    tournamentId: entry.tournamentId,
    clubName: entry.clubName,
    challengerName: me.name,
    opponentName: entry.playerName,
    needsApproval: needsApproval,
  );

  // Lock both players into a shared tee time. No ladder movement here — the
  // winner is decided when the scorecard is submitted.
  play.lockInChallenge(
    TeeSheetEntry(
      opponentName: entry.playerName,
      tournamentName: entry.tournamentName,
      courseName: entry.courseName,
      teeTime: entry.teeTime,
      date: 'This weekend',
    ),
  );

  if (!context.mounted) return;
  final firstName = entry.playerName.split(' ').first;

  if (needsApproval) {
    await _notice(
      context,
      'Challenge sent',
      "Your challenge to ${entry.playerName} was sent to the ${entry.clubName} admins, and you're locked "
          "into a shared tee time at ${entry.teeTime}. It counts once approved and the round is scored.",
    );
    return;
  }

  final viewTeeSheet = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Challenge set'),
      content: Text(
        "You're locked in with $firstName at ${entry.teeTime} for ${entry.tournamentName}. "
        "The winner is decided when the scorecard is submitted.",
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
