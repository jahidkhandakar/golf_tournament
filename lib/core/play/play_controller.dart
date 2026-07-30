import 'package:flutter/foundation.dart';

import '../permission/club_role.dart';

/// One paired tee time, created when a challenge is accepted — both players
/// are locked into the same slot.
class TeeSheetEntry {
  const TeeSheetEntry({
    required this.opponentName,
    required this.tournamentName,
    required this.courseName,
    required this.teeTime,
    required this.date,
  });

  final String opponentName;
  final String tournamentName;
  final String courseName;
  final String teeTime;
  final String date;
}

/// App-wide mutable state for the club/tournament/challenge flow, backed by
/// plain [ValueNotifier]s (same lightweight pattern as LocationState /
/// ThemeController). A player can only be challenged once both are in the
/// same tournament; joining a tournament may first require joining its club.
///
/// Seeded to match the logged-in user's identity (see
/// MockUserProfileRepository — Jahid, member of Riverbend & Oakmont, already
/// entered in the Riverbend Championship at the Championship Course). That
/// makes every Top 50 challenge condition self-evident against the mock data:
///   - Riverbend Championship Course players → challenge right away
///   - Alex Rivera (same tournament, Riverbend West Course) → locked
///   - Oakmont players → same club, just join their tournament
///   - Pine Valley / Hill Country / Lakeside → join the club first
class PlayController {
  final ValueNotifier<Set<String>> joinedClubs =
      ValueNotifier<Set<String>>({'Riverbend Golf Club', 'Oakmont Hills'});

  /// Clubs the user created (they are the Club Creator). Seeded so the logged-in
  /// user runs Riverbend — the club behind the seeded tournament / tee sheet.
  final ValueNotifier<Set<String>> createdClubs =
      ValueNotifier<Set<String>>({'Riverbend Golf Club'});

  /// Clubs where the user has been appointed a sub-admin.
  final ValueNotifier<Set<String>> subAdminClubs = ValueNotifier<Set<String>>({});

  /// Holds `tournamentId@courseName` keys — a challenge requires both players
  /// to share the same tournament AND the same golf course, so the course is
  /// part of the key (a tournament could span multiple courses).
  final ValueNotifier<Set<String>> joinedTournaments =
      ValueNotifier<Set<String>>({tournamentKey('t_riverbend', 'Riverbend Championship Course')});

  final ValueNotifier<List<TeeSheetEntry>> teeSheet = ValueNotifier<List<TeeSheetEntry>>([]);

  static String tournamentKey(String tournamentId, String courseName) => '$tournamentId@$courseName';

  bool isInClub(String clubName) => joinedClubs.value.contains(clubName);

  /// The user's role in [clubName], most-privileged first: a creator is also a
  /// member, but Creator wins.
  ClubRole roleIn(String clubName) {
    if (createdClubs.value.contains(clubName)) return ClubRole.creator;
    if (subAdminClubs.value.contains(clubName)) return ClubRole.subAdmin;
    if (joinedClubs.value.contains(clubName)) return ClubRole.member;
    return ClubRole.nonMember;
  }

  bool isInTournament(String tournamentId, String courseName) =>
      joinedTournaments.value.contains(tournamentKey(tournamentId, courseName));

  void joinClub(String clubName) {
    joinedClubs.value = {...joinedClubs.value, clubName};
  }

  void joinTournament(String tournamentId, String courseName) {
    joinedTournaments.value = {...joinedTournaments.value, tournamentKey(tournamentId, courseName)};
  }

  /// Adds a paired tee time, ignoring a duplicate against the same opponent.
  void lockInChallenge(TeeSheetEntry entry) {
    if (teeSheet.value.any((e) => e.opponentName == entry.opponentName)) return;
    teeSheet.value = [...teeSheet.value, entry];
  }
}
