import 'entities/leaderboard_entry.dart';

/// The Top 50 (and Club Leaderboard) ranking rule: **position-based movement**,
/// per the client. It's a challenge ladder — beat a player ranked above you and
/// you take their position; everyone in between slides down one.
///
/// This is the single "swap-later" ranking function. If the exact rules for the
/// loser's drop or a new player's entry differ from the standard ladder below,
/// this is the only place that changes.
///
/// TODO(stan): confirm — (1) does the loser only drop when displaced (current
/// behaviour), or also on their own loss? (2) where does a brand-new player
/// enter the ladder?
List<LeaderboardEntry> applyChallengeResult(
  List<LeaderboardEntry> ladder, {
  required String winnerName,
  required String loserName,
}) {
  final sorted = [...ladder]..sort((a, b) => a.position.compareTo(b.position));
  final winnerIndex = sorted.indexWhere((e) => e.playerName == winnerName);
  final loserIndex = sorted.indexWhere((e) => e.playerName == loserName);

  // You only move up by beating someone ranked above you. If the loser was at or
  // below the winner, the ladder is unchanged.
  if (winnerIndex < 0 || loserIndex < 0 || loserIndex >= winnerIndex) {
    return ladder;
  }

  // Winner jumps into the loser's slot; everyone from the loser down to the
  // winner's old spot shifts down one (the loser ends up just below the winner).
  final winner = sorted.removeAt(winnerIndex);
  sorted.insert(loserIndex, winner);

  return [
    for (var i = 0; i < sorted.length; i++) sorted[i].copyWith(position: i + 1),
  ];
}
