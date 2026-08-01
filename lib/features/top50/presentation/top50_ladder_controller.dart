import 'package:flutter/foundation.dart';

import '../domain/entities/leaderboard_entry.dart';
import '../domain/ladder_movement.dart';
import '../domain/repositories/leaderboard_repository.dart';

/// Holds the live Top 50 ladder so challenge results can move players in place.
/// Backed by a [ValueNotifier] (same lightweight pattern as PlayController), and
/// registered as a singleton so the Top 50 page and the challenge flow share one
/// source of truth. Loaded lazily from [LeaderboardRepository] on first view.
class Top50LadderController {
  Top50LadderController(this._repository);

  final LeaderboardRepository _repository;

  final ValueNotifier<List<LeaderboardEntry>> ladder =
      ValueNotifier<List<LeaderboardEntry>>([]);

  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    ladder.value = await _repository.getLeaderboard();
  }

  /// Applies a completed challenge result to the ladder — called when the round's
  /// scorecard is submitted (§6), not when the challenge is created.
  void recordResult({required String winnerName, required String loserName}) {
    ladder.value = applyChallengeResult(
      ladder.value,
      winnerName: winnerName,
      loserName: loserName,
    );
  }
}
