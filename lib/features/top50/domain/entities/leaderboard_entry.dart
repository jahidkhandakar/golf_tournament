import 'package:equatable/equatable.dart';

class LeaderboardEntry extends Equatable {
  const LeaderboardEntry({
    required this.playerName,
    required this.handicap,
    required this.roundsPlayed,
    required this.distanceMiles,
    required this.clubName,
    required this.tournamentId,
    required this.tournamentName,
    required this.courseName,
    required this.teeTime,
  });

  final String playerName;
  final double handicap;
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

  @override
  List<Object?> get props =>
      [playerName, handicap, roundsPlayed, distanceMiles, clubName, tournamentId, tournamentName, courseName, teeTime];
}
