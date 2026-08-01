import 'package:flutter/foundation.dart';

/// The logged-in user's Club Leaderboard participation, per club. Opt-in is
/// **off by default** — the member turns it on from their club page and can opt
/// out any time (Part 2). On opt-in the position is seeded from handicap order
/// among the ranked members; after that it only moves through challenges.
///
/// Backed by a [ValueNotifier] (same pattern as PlayController) and registered
/// as a singleton so the leaderboard tab reacts to changes.
class ClubLeaderboardState {
  /// clubName -> the user's stored leaderboard position. Absent = opted out.
  final ValueNotifier<Map<String, int>> positions = ValueNotifier<Map<String, int>>({});

  bool isOptedIn(String clubName) => positions.value.containsKey(clubName);

  int? positionIn(String clubName) => positions.value[clubName];

  void optIn(String clubName, {required int seededPosition}) {
    positions.value = {...positions.value, clubName: seededPosition};
  }

  void optOut(String clubName) {
    positions.value = {...positions.value}..remove(clubName);
  }
}
