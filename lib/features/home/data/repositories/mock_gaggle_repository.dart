import '../../domain/entities/gaggle.dart';
import '../../domain/repositories/gaggle_repository.dart';

/// Hardcoded stand-in for a real API-backed repository.
class MockGaggleRepository implements GaggleRepository {
  static final List<Gaggle> _gaggles = [
    Gaggle(
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
    Gaggle(
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
    Gaggle(
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
  Future<List<Gaggle>> getGaggles() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _gaggles;
  }
}
