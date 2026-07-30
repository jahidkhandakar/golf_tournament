import '../../domain/entities/tournament.dart';
import '../../domain/repositories/tournament_repository.dart';

/// In-memory stand-in for the real tournament API. Seeded with the Riverbend
/// Championship (matching the tee sheet + Top 50 mocks) and keeps any newly
/// created tournaments for the session so the create flow feels real.
class MockTournamentRepository implements TournamentRepository {
  final List<Tournament> _tournaments = [
    Tournament(
      id: 't_riverbend',
      name: 'Riverbend Championship',
      clubName: 'Riverbend Golf Club',
      format: 'Stroke Play',
      courseName: 'Riverbend Championship Course',
      date: DateTime.now().add(const Duration(days: 5)),
      firstTeeTime: '7:10 AM',
      intervalMinutes: 10,
      teeBoxes: 18,
      teamsPerTeeBox: 3,
      golfCourseEmail: 'proshop@riverbendgolf.example',
      registeredPlayers: 40,
    ),
  ];

  @override
  Future<Tournament> createTournament(Tournament tournament) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _tournaments.insert(0, tournament);
    return tournament;
  }

  @override
  Future<List<Tournament>> getMyTournaments() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_tournaments);
  }

  @override
  Future<Tournament?> getTournament(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (final t in _tournaments) {
      if (t.id == id) return t;
    }
    return null;
  }
}
