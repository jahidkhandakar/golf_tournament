import 'package:equatable/equatable.dart';

/// A casual, player-organized round — lighter weight than a club [ClubRound]
/// and never counted toward handicap.
class Outing extends Equatable {
  const Outing({
    required this.id,
    required this.title,
    required this.hostName,
    required this.format,
    required this.dateTime,
    required this.currentPlayers,
    required this.maxPlayers,
    required this.distanceMiles,
  });

  final String id;
  final String title;
  final String hostName;
  final String format;
  final DateTime dateTime;
  final int currentPlayers;
  final int maxPlayers;
  final double distanceMiles;

  @override
  List<Object?> get props => [
        id,
        title,
        hostName,
        format,
        dateTime,
        currentPlayers,
        maxPlayers,
        distanceMiles,
      ];
}
