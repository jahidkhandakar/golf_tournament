import '../../domain/entities/outing.dart';
import '../../domain/repositories/outing_repository.dart';

/// Hardcoded stand-in for a real API-backed repository.
class MockOutingRepository implements OutingRepository {
  static final List<Outing> _outings = [
    Outing(
      id: 'o1',
      title: 'Saturday Morning Nine',
      hostName: 'Marcus T.',
      format: 'Scramble',
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 8)),
      currentPlayers: 3,
      maxPlayers: 10,
      distanceMiles: 2.1,
    ),
    Outing(
      id: 'o2',
      title: 'After-Work Twilight Round',
      hostName: 'Dana R.',
      format: 'Stroke Play',
      dateTime: DateTime.now().add(const Duration(days: 3, hours: 17)),
      currentPlayers: 6,
      maxPlayers: 10,
      distanceMiles: 6.4,
    ),
    Outing(
      id: 'o3',
      title: 'Beginner-Friendly Outing',
      hostName: 'Priya K.',
      format: 'Best Ball',
      dateTime: DateTime.now().add(const Duration(days: 6, hours: 9)),
      currentPlayers: 4,
      maxPlayers: 10,
      distanceMiles: 9.8,
    ),
  ];

  @override
  Future<List<Outing>> getOutings() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _outings;
  }
}
