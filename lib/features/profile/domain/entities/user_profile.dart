import 'package:equatable/equatable.dart';

import '../../../../core/user/user_tier.dart';

/// The current golfer's identity + tier — shown in the drawer header, the
/// Profile screen, and used to seed the club/tournament the user is already
/// part of (see PlayController).
class UserProfile extends Equatable {
  const UserProfile({
    required this.name,
    required this.tier,
    required this.clubHandicap,
    this.globalHandicap,
    required this.homeClub,
    required this.currentTournament,
    required this.currentCourse,
  });

  final String name;
  final UserTier tier;

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
      [name, tier, clubHandicap, globalHandicap, homeClub, currentTournament, currentCourse];
}
