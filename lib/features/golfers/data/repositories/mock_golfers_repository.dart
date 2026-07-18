import '../../domain/entities/nearby_golfer.dart';
import '../../domain/repositories/golfers_repository.dart';

/// Hardcoded stand-in for a real API-backed repository. Distances span the
/// 60 mi urban and 120 mi rural search radii (see LocationState).
class MockGolfersRepository implements GolfersRepository {
  static const List<NearbyGolfer> _golfers = [
    NearbyGolfer(
      id: 'gf1',
      name: 'Marcus Thompson',
      handicap: 8.2,
      distanceMiles: 3.4,
      homeClub: 'Riverbend Golf Club',
      roundsPlayed: 34,
      bio: 'Weekend regular at Riverbend, always up for a scramble.',
    ),
    NearbyGolfer(
      id: 'gf2',
      name: 'Dana Reyes',
      handicap: 14.6,
      distanceMiles: 6.1,
      homeClub: 'Oakmont Hills',
      roundsPlayed: 21,
      bio: 'Learning the game, happy to join any beginner-friendly outing.',
    ),
    NearbyGolfer(
      id: 'gf3',
      name: 'Priya Kapoor',
      handicap: 11.0,
      distanceMiles: 9.8,
      homeClub: 'Riverbend Golf Club',
      roundsPlayed: 28,
      bio: 'Prefer stroke play, usually free on weekend mornings.',
    ),
    NearbyGolfer(
      id: 'gf4',
      name: 'Sam Ortiz',
      handicap: 19.4,
      distanceMiles: 12.3,
      homeClub: 'Pine Valley Muni',
      roundsPlayed: 15,
      bio: 'New to the area, looking to meet other golfers.',
    ),
    NearbyGolfer(
      id: 'gf5',
      name: 'Erin Walsh',
      handicap: 2.1,
      distanceMiles: 15.7,
      homeClub: 'Oakmont Hills',
      roundsPlayed: 41,
      bio: 'Competitive player, top of the club leaderboard most months.',
    ),
    NearbyGolfer(
      id: 'gf6',
      name: 'Devon Lee',
      handicap: 5.2,
      distanceMiles: 22.4,
      homeClub: 'Pine Valley Muni',
      roundsPlayed: 30,
      bio: 'Enjoys challenge matches, open to most formats.',
    ),
    NearbyGolfer(
      id: 'gf7',
      name: 'Jordan Blake',
      handicap: 8.1,
      distanceMiles: 74,
      homeClub: 'Hill Country Club',
      roundsPlayed: 15,
      bio: 'Out in the hill country, always keen for a weekend game.',
    ),
    NearbyGolfer(
      id: 'gf8',
      name: 'Casey Nguyen',
      handicap: 9.4,
      distanceMiles: 108,
      homeClub: 'Lakeside Links',
      roundsPlayed: 18,
      bio: 'Lakeside regular, happy to host visitors.',
    ),
  ];

  @override
  Future<List<NearbyGolfer>> getNearbyGolfers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _golfers;
  }
}
