import 'package:equatable/equatable.dart';

class ClubMember extends Equatable {
  const ClubMember({
    required this.id,
    required this.name,
    required this.clubHandicap,
    this.roundsPlayed = 12,
    this.leaderboardOptedIn = true,
    this.leaderboardPosition,
    this.isAdmin = false,
  });

  final String id;
  final String name;

  /// Handicap within this club — clubs set their own rules, so this is the
  /// number that *seeds* the Club Leaderboard position (not the global handicap).
  final double clubHandicap;

  /// Scored rounds at this club. A member needs 3+ for an established handicap
  /// before they can be ranked on the leaderboard.
  final int roundsPlayed;

  /// The Club Leaderboard is opt-in (default off for real users; seeded true for
  /// mock members so the board has content).
  final bool leaderboardOptedIn;

  /// Stored ladder position on the Club Leaderboard. Seeded from handicap order
  /// at opt-in, then only moves through challenges — the tab sorts by THIS, not
  /// by handicap. Null when the member isn't ranked.
  final int? leaderboardPosition;

  final bool isAdmin;

  /// Ranked = opted in with an established handicap and a stored position.
  bool get isRanked => leaderboardOptedIn && roundsPlayed >= 3 && leaderboardPosition != null;

  ClubMember copyWith({int? leaderboardPosition}) => ClubMember(
        id: id,
        name: name,
        clubHandicap: clubHandicap,
        roundsPlayed: roundsPlayed,
        leaderboardOptedIn: leaderboardOptedIn,
        leaderboardPosition: leaderboardPosition ?? this.leaderboardPosition,
        isAdmin: isAdmin,
      );

  @override
  List<Object?> get props =>
      [id, name, clubHandicap, roundsPlayed, leaderboardOptedIn, leaderboardPosition, isAdmin];
}
