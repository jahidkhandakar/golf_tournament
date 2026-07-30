import '../../domain/entities/nearby_golfer.dart';
import '../../domain/repositories/golfers_repository.dart';

/// Hardcoded stand-in for a real API-backed repository. One entry per named
/// golfer (all except the logged-in user), so each shows their own photo.
/// Distances span the 60 mi urban and 120 mi rural search radii.
class MockGolfersRepository implements GolfersRepository {
  static const List<NearbyGolfer> _golfers = [
    NearbyGolfer(
      id: 'gf1',
      name: 'Marcus Thompson',
      globalHandicap: 3.4,
      distanceMiles: 3.4,
      homeClub: 'Riverbend Golf Club',
      roundsPlayed: 41,
      bio: 'Weekend regular at Riverbend, always up for a scramble.',
    ),
    NearbyGolfer(
      id: 'gf2',
      name: 'Dana Reyes',
      globalHandicap: 7.5,
      distanceMiles: 6.1,
      homeClub: 'Oakmont Hills',
      roundsPlayed: 26,
      bio: 'Happy to join any beginner-friendly outing.',
    ),
    NearbyGolfer(
      id: 'gf3',
      name: 'Priya Kapoor',
      globalHandicap: 4.0,
      distanceMiles: 9.8,
      homeClub: 'Riverbend Golf Club',
      roundsPlayed: 28,
      bio: 'Prefer stroke play, usually free on weekend mornings.',
    ),
    NearbyGolfer(
      id: 'gf4',
      name: 'Sam Ortiz',
      globalHandicap: null, // hasn't published a global handicap
      distanceMiles: 12.3,
      homeClub: 'Pine Valley Muni',
      roundsPlayed: 19,
      bio: 'Looking to meet other golfers around the area.',
    ),
    NearbyGolfer(
      id: 'gf5',
      name: 'Erin Walsh',
      globalHandicap: 2.1,
      distanceMiles: 15.7,
      homeClub: 'Oakmont Hills',
      roundsPlayed: 34,
      bio: 'Competitive player, top of the club leaderboard most months.',
    ),
    NearbyGolfer(
      id: 'gf6',
      name: 'Devon Lee',
      globalHandicap: 5.2,
      distanceMiles: 22.4,
      homeClub: 'Pine Valley Muni',
      roundsPlayed: 22,
      bio: 'Enjoys challenge matches, open to most formats.',
    ),
    NearbyGolfer(
      id: 'gf7',
      name: 'Alex Rivera',
      globalHandicap: 3.7,
      distanceMiles: 30,
      homeClub: 'Hill Country Club',
      roundsPlayed: 31,
      bio: 'Plays the West course, keen for a weekend round.',
    ),
    NearbyGolfer(
      id: 'gf8',
      name: 'Riley Foster',
      globalHandicap: 10.2,
      distanceMiles: 45,
      homeClub: 'Pine Valley Muni',
      roundsPlayed: 12,
      bio: 'Newer to the game, friendly and always learning.',
    ),
    NearbyGolfer(
      id: 'gf9',
      name: 'Taylor Brooks',
      globalHandicap: 11.6,
      distanceMiles: 52,
      homeClub: 'Lakeside Links',
      roundsPlayed: 20,
      bio: 'Casual rounds and the odd club medal.',
    ),
    NearbyGolfer(
      id: 'gf10',
      name: 'Jordan Blake',
      globalHandicap: 8.1,
      distanceMiles: 74,
      homeClub: 'Hill Country Club',
      roundsPlayed: 15,
      bio: 'Out in the hill country, always keen for a weekend game.',
    ),
    NearbyGolfer(
      id: 'gf11',
      name: 'Casey Nguyen',
      globalHandicap: 9.4,
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
