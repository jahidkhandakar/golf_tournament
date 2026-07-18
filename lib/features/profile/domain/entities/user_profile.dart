import 'package:equatable/equatable.dart';

import '../../../../core/user/user_tier.dart';

/// The current golfer's identity + tier — shown in the drawer header, the
/// Profile screen, and used to seed the club/tournament the user is already
/// part of (see PlayController).
class UserProfile extends Equatable {
  const UserProfile({
    required this.name,
    required this.tier,
    required this.handicap,
    required this.homeClub,
    required this.currentTournament,
    required this.currentCourse,
  });

  final String name;
  final UserTier tier;
  final double handicap;

  /// The club the user is a member of.
  final String homeClub;

  /// The tournament (and course) the user is currently entered in — this is
  /// what determines which Top 50 players they can challenge right away.
  final String currentTournament;
  final String currentCourse;

  @override
  List<Object?> get props => [name, tier, handicap, homeClub, currentTournament, currentCourse];
}
