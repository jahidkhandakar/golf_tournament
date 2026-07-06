import 'package:equatable/equatable.dart';

class LeaderboardEntry extends Equatable {
  const LeaderboardEntry({
    required this.rank,
    required this.playerName,
    required this.handicap,
    required this.roundsPlayed,
  });

  final int rank;
  final String playerName;
  final double handicap;
  final int roundsPlayed;

  @override
  List<Object?> get props => [rank, playerName, handicap, roundsPlayed];
}
