import '../../domain/entities/club_round.dart';
import '../../domain/repositories/club_round_repository.dart';

/// Hardcoded stand-in for a real API-backed repository.
class MockClubRoundRepository implements ClubRoundRepository {
  static final List<ClubRound> _clubRounds = [
    ClubRound(
      id: 'g1',
      clubName: 'Riverbend Golf Club',
      format: 'Stroke Play',
      date: DateTime.now().add(const Duration(days: 2)),
      teeTime: '7:40 AM',
      courseName: 'Riverbend Championship Course',
      currentPlayers: 24,
      maxPlayers: 32,
      distanceMiles: 4.2,
    ),
    ClubRound(
      id: 'g2',
      clubName: 'Oakmont Hills',
      format: 'Scramble',
      date: DateTime.now().add(const Duration(days: 5)),
      teeTime: '8:15 AM',
      courseName: 'Oakmont North',
      currentPlayers: 12,
      maxPlayers: 24,
      distanceMiles: 11.6,
    ),
    ClubRound(
      id: 'g3',
      clubName: 'Pine Valley Muni',
      format: 'Best Ball',
      date: DateTime.now().add(const Duration(days: 9)),
      teeTime: '1:00 PM',
      courseName: 'Pine Valley East',
      currentPlayers: 30,
      maxPlayers: 40,
      distanceMiles: 18.9,
    ),
  ];

  @override
  Future<List<ClubRound>> getClubRounds() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _clubRounds;
  }
}
