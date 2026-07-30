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
    // A club the user is a *member* of — demonstrates direct registration.
    Tournament(
      id: 't_oakmont',
      name: 'Oakmont Summer Open',
      clubName: 'Oakmont Hills',
      format: 'Best Ball',
      courseName: 'Oakmont North',
      date: DateTime.now().add(const Duration(days: 7)),
      firstTeeTime: '8:00 AM',
      intervalMinutes: 10,
      teeBoxes: 9,
      teamsPerTeeBox: 2,
      golfCourseEmail: 'events@oakmonthills.example',
      registeredPlayers: 12,
    ),
    // A club the user is *not* in — demonstrates Request to Play.
    Tournament(
      id: 't_pinevalley',
      name: 'Pine Valley Classic',
      clubName: 'Pine Valley Muni',
      format: 'Scramble',
      courseName: 'Pine Valley East',
      date: DateTime.now().add(const Duration(days: 10)),
      firstTeeTime: '1:00 PM',
      intervalMinutes: 12,
      teeBoxes: 18,
      teamsPerTeeBox: 2,
      registeredPlayers: 30,
    ),
  ];

  @override
  Future<Tournament> createTournament(Tournament tournament) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _tournaments.insert(0, tournament);
    return tournament;
  }

  @override
  Future<List<Tournament>> getAllTournaments() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_tournaments);
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
