import 'entities/leaderboard_entry.dart';

/// The Top 50 and Club Leaderboard ranking rule: position-based movement.
/// A challenge ladder where the winner takes the loser's position and the
/// loser drops by a fixed formula. This file is the single source of truth
/// for every ladder move: challenge results, new player entry, and decline
/// penalties.
///
/// Rules implemented here:
///   Challenge win:  winner takes the loser's exact position. The loser drops
///                   by min(5, distance), where distance is the gap between
///                   the winner's rank before the challenge and the loser's
///                   rank. The loser can never drop below the last position.
///   New player:     an unranked player who beats someone in the top half of
///                   the list enters at the midpoint. Beating someone in the
///                   bottom half enters at the 90 percent mark. Everyone at or
///                   below the entry point shifts down one. On a capped list
///                   (Top 50) the last player falls off.
///   Decline:        declining while co-registered in the same event drops the
///                   decliner 3 positions, floored at the bottom of the list.

/// Applies a completed challenge between two ranked players.
/// Call this when the round's scores are submitted, not when the challenge is
/// created. The outcome comes from the scorecard.
List<LeaderboardEntry> applyChallengeResult(
  List<LeaderboardEntry> ladder, {
  required String winnerName,
  required String loserName,
}) {
  final sorted = [...ladder]..sort((a, b) => a.position.compareTo(b.position));
  final winnerIndex = sorted.indexWhere((e) => e.playerName == winnerName);
  final loserIndex = sorted.indexWhere((e) => e.playerName == loserName);

  // A player only moves up by beating someone ranked above them. If the loser
  // was at or below the winner, positions do not change.
  if (winnerIndex < 0 || loserIndex < 0 || loserIndex >= winnerIndex) {
    return ladder;
  }

  final winnerRankBefore = winnerIndex + 1;
  final loserRankBefore = loserIndex + 1;

  // Loser drops the smaller of 5 spots or the distance between the winner's
  // prior rank and the loser's rank.
  final distance = winnerRankBefore - loserRankBefore;
  final drop = distance < 5 ? distance : 5;

  // Step 1: winner takes the loser's slot. Everyone from the loser down to the
  // winner's old slot shifts down one.
  final winner = sorted.removeAt(winnerIndex);
  sorted.insert(loserIndex, winner);

  // Step 2: move the loser down to their post-drop position. After step 1 the
  // loser sits at index loserIndex + 1 (rank loserRankBefore + 1), so they
  // still need to fall (drop - 1) more places, bounded by the bottom of the
  // list.
  final loserCurrentIndex = loserIndex + 1;
  var loserTargetIndex = loserIndex + drop; // 0-based index of rank loserRankBefore + drop
  if (loserTargetIndex > sorted.length - 1) loserTargetIndex = sorted.length - 1;
  if (loserTargetIndex > loserCurrentIndex) {
    final loser = sorted.removeAt(loserCurrentIndex);
    sorted.insert(loserTargetIndex, loser);
  }

  return _renumber(sorted);
}

/// Enters an unranked player onto the ladder after they beat a ranked player.
///
/// [beatenRank] is the rank of the player they defeated at the time of the
/// challenge. [maxSize] caps the list (50 for the Top 50). Pass null for an
/// uncapped list (Club Leaderboard, where every eligible member is ranked).
///
/// Entry position scales with the list size:
///   beaten player in the top half     -> enter at the midpoint
///   beaten player in the bottom half  -> enter at the 90 percent mark
/// On a 50 player list that is rank 25 and rank 45, matching the spec.
List<LeaderboardEntry> enterNewPlayer(
  List<LeaderboardEntry> ladder, {
  required LeaderboardEntry newPlayer,
  required int beatenRank,
  int? maxSize,
}) {
  final sorted = [...ladder]..sort((a, b) => a.position.compareTo(b.position));
  final n = sorted.length;
  if (n == 0) {
    return [newPlayer.copyWith(position: 1)];
  }

  final midpoint = (n / 2).ceil();
  final entryRank = beatenRank <= midpoint ? midpoint : (n * 0.9).round().clamp(1, n);

  final entryIndex = (entryRank - 1).clamp(0, n);
  sorted.insert(entryIndex, newPlayer);

  // On a capped list the player at the bottom falls off.
  if (maxSize != null && sorted.length > maxSize) {
    sorted.removeLast();
  }

  return _renumber(sorted);
}

/// Applies the 3-position decline penalty. Use when a player declines a
/// challenge while co-registered in the same event, or ignores the challenge
/// notification (an ignore counts as a decline). Floored at the bottom of the
/// list.
List<LeaderboardEntry> applyDeclinePenalty(
  List<LeaderboardEntry> ladder, {
  required String declinerName,
  int spots = 3,
}) {
  final sorted = [...ladder]..sort((a, b) => a.position.compareTo(b.position));
  final index = sorted.indexWhere((e) => e.playerName == declinerName);
  if (index < 0) return ladder;

  var target = index + spots;
  if (target > sorted.length - 1) target = sorted.length - 1;
  if (target == index) return ladder;

  final decliner = sorted.removeAt(index);
  sorted.insert(target, decliner);

  return _renumber(sorted);
}

List<LeaderboardEntry> _renumber(List<LeaderboardEntry> sorted) => [
      for (var i = 0; i < sorted.length; i++) sorted[i].copyWith(position: i + 1),
    ];
