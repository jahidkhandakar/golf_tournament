import 'package:equatable/equatable.dart';

/// A club-run tournament round a player can request to join. Shown to users
/// as a "Club" — the same idea as a club's own tournament, surfaced globally.
class ClubRound extends Equatable {
  const ClubRound({
    required this.id,
    required this.clubName,
    required this.format,
    required this.date,
    required this.teeTime,
    required this.courseName,
    required this.currentPlayers,
    required this.maxPlayers,
    required this.distanceMiles,
  });

  final String id;
  final String clubName;
  final String format;
  final DateTime date;
  final String teeTime;
  final String courseName;
  final int currentPlayers;
  final int maxPlayers;
  final double distanceMiles;

  @override
  List<Object?> get props => [
        id,
        clubName,
        format,
        date,
        teeTime,
        courseName,
        currentPlayers,
        maxPlayers,
        distanceMiles,
      ];
}
