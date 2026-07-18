import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../core/play/play_controller.dart';
import '../../../core/router/app_routes.dart';
import '../domain/entities/leaderboard_entry.dart';

/// Sends a challenge to [entry]'s player and (mock) auto-accepts it, locking
/// both players into the same tee time and adding it to the tee sheet.
/// Shared by the Top 50 row's illuminated Challenge button and the player
/// detail page. Only call this once both players are in the same tournament.
Future<void> sendChallenge(BuildContext context, LeaderboardEntry entry) async {
  final play = GetIt.instance<PlayController>();
  final firstName = entry.playerName.split(' ').first;

  play.lockInChallenge(
    TeeSheetEntry(
      opponentName: entry.playerName,
      tournamentName: entry.tournamentName,
      courseName: entry.courseName,
      teeTime: entry.teeTime,
      date: 'This weekend',
    ),
  );

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
