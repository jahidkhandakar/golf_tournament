import 'package:equatable/equatable.dart';

/// A golfer browsable from the Profile tab — within the user's search
/// radius (see [LocationState]), not the current user's own profile.
class NearbyGolfer extends Equatable {
  const NearbyGolfer({
    required this.id,
    required this.name,
    required this.globalHandicap,
    required this.distanceMiles,
    required this.homeClub,
    required this.roundsPlayed,
    required this.bio,
  });

  final String id;
  final String name;

  /// The golfer's global (worldwide) handicap, shown so other players can size
  /// them up for a round anywhere. Optional — not every golfer keeps one.
  final double? globalHandicap;
  final double distanceMiles;
  final String homeClub;
  final int roundsPlayed;
  final String bio;

  @override
  List<Object?> get props => [id, name, globalHandicap, distanceMiles, homeClub, roundsPlayed, bio];
}
