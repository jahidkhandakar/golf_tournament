import 'package:equatable/equatable.dart';

import '../../../../core/user/user_tier.dart';

/// Profile gender. Used only on the score entry screens so whoever is entering
/// KP and long-drive placard results knows which category slot a player
/// belongs in. Nothing else in the app reads it.
enum Gender { unspecified, male, female }

/// The current golfer's identity + tier — shown in the drawer header, the
/// Profile screen, and used to seed the club/tournament the user is already
/// part of (see PlayController).
class UserProfile extends Equatable {
  const UserProfile({
    required this.name,
    required this.tier,
    this.gender = Gender.unspecified,
    this.isSenior = false,
    required this.clubHandicap,
    this.globalHandicap,
    required this.homeClub,
    required this.currentTournament,
    required this.currentCourse,
  });

  final String name;
  final UserTier tier;

  /// Shown next to the name on entry screens for KP and long-drive slotting.
  final Gender gender;

  /// True when the player's age is at or above the club's gold tee age
  /// threshold (default 62). Same threshold the tee box engine uses.
  final bool isSenior;

  /// Handicap at the user's home club — used wherever their club standing
  /// matters (Club Leaderboard, tee box color).
  final double clubHandicap;

  /// Optional global (worldwide) handicap. Not mandatory — when set, it's shown
  /// on the profile so players elsewhere can size the user up for a round.
  final double? globalHandicap;

  /// The club the user is a member of.
  final String homeClub;

  /// The tournament (and course) the user is currently entered in — this is
  /// what determines which Top 50 players they can challenge right away.
  final String currentTournament;
  final String currentCourse;

  @override
  List<Object?> get props =>
      [name, tier, gender, isSenior, clubHandicap, globalHandicap, homeClub, currentTournament, currentCourse];
}
