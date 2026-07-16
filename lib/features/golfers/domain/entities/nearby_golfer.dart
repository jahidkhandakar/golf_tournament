import 'package:equatable/equatable.dart';

/// A golfer browsable from the Profile tab — within the user's search
/// radius (see [LocationState]), not the current user's own profile.
class NearbyGolfer extends Equatable {
  const NearbyGolfer({
    required this.id,
    required this.name,
    required this.handicap,
    required this.distanceMiles,
    required this.homeClub,
    required this.roundsPlayed,
    required this.bio,
  });

  final String id;
  final String name;
  final double handicap;
  final double distanceMiles;
  final String homeClub;
  final int roundsPlayed;
  final String bio;

  @override
  List<Object?> get props => [id, name, handicap, distanceMiles, homeClub, roundsPlayed, bio];
}
