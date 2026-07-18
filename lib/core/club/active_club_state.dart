import 'package:flutter/foundation.dart';

/// Which club the Club tab is currently showing. My Clubs (the list) sets
/// this when you tap a club; the Club tab (the detail view) reads it. Plain
/// [ValueNotifier], same pattern as LocationState / PlayController.
///
/// Defaults to the user's home club (see MockUserProfileRepository / the
/// PlayController seed — Riverbend, id `c1`).
class ActiveClubState {
  final ValueNotifier<String> activeClubId = ValueNotifier<String>('c1');

  void select(String clubId) => activeClubId.value = clubId;
}
