import 'package:equatable/equatable.dart';

class LeaderboardEntry extends Equatable {
  const LeaderboardEntry({
    required this.position,
    required this.playerName,
    required this.globalHandicap,
    required this.roundsPlayed,
    required this.distanceMiles,
    required this.clubName,
    required this.tournamentId,
    required this.tournamentName,
    required this.courseName,
    required this.teeTime,
    this.isCurrentUser = false,
  });

  /// The player's rank on the ladder (1 = top). This is a *stored position*,
  /// not a computed sort — challenge results move players up/down by position
  /// (see ladder_movement.dart), per the client's "position-based movement".
  final int position;

  final String playerName;

  /// The logged-in user's own row — rendered distinctly and never challengeable.
  final bool isCurrentUser;

  /// Global (worldwide) handicap shown on the cross-club Top 50 ladder.
  /// Optional — Top 50 rank is position-based, not handicap-based.
  final double? globalHandicap;
  final int roundsPlayed;
  final double distanceMiles;

  /// The club this player belongs to — you must be a member to enter their
  /// tournament.
  final String clubName;

  /// The tournament this player is currently entered in. You can only
  /// challenge them once you've joined the same tournament.
  final String tournamentId;
  final String tournamentName;
  final String courseName;
  final String teeTime;

  LeaderboardEntry copyWith({int? position}) => LeaderboardEntry(
        position: position ?? this.position,
        playerName: playerName,
        globalHandicap: globalHandicap,
        roundsPlayed: roundsPlayed,
        distanceMiles: distanceMiles,
        clubName: clubName,
        tournamentId: tournamentId,
        tournamentName: tournamentName,
        courseName: courseName,
        teeTime: teeTime,
        isCurrentUser: isCurrentUser,
      );

  @override
  List<Object?> get props => [
        position,
        playerName,
        isCurrentUser,
        globalHandicap,
        roundsPlayed,
        distanceMiles,
        clubName,
        tournamentId,
        tournamentName,
        courseName,
        teeTime,
      ];
}
