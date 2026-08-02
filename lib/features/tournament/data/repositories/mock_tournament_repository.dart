import '../../domain/entities/contest_config.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/repositories/tournament_repository.dart';

/// In-memory stand-in for the real tournament API. Seeded with the Riverbend
/// Championship (matching the tee sheet + Top 50 mocks) and keeps any newly
/// created tournaments for the session so the create flow feels real.
class MockTournamentRepository implements TournamentRepository {
  /// Tee-off at [hour]:[minute] on the day [daysFromNow] from now — used so the
  /// 48h/24h cutoffs land at predictable, demoable times.
  static DateTime _teeOff(int daysFromNow, int hour, int minute) {
    final day = DateTime.now().add(Duration(days: daysFromNow));
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  final List<Tournament> _tournaments = [
    Tournament(
      id: 't_riverbend',
      name: 'Riverbend Championship',
      clubName: 'Riverbend Golf Club',
      zone: 'Austin, TX',
      format: 'Stroke Play',
      courseName: 'Riverbend Championship Course',
      date: _teeOff(5, 7, 10),
      firstTeeTime: '7:10 AM',
      teeOff: _teeOff(5, 7, 10),
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
      zone: 'Austin, TX',
      format: 'Best Ball',
      courseName: 'Oakmont North',
      date: _teeOff(7, 8, 0),
      firstTeeTime: '8:00 AM',
      teeOff: _teeOff(7, 8, 0),
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
      zone: 'Dallas, TX',
      format: 'Scramble',
      courseName: 'Pine Valley East',
      date: _teeOff(10, 13, 0),
      firstTeeTime: '1:00 PM',
      teeOff: _teeOff(10, 13, 0),
      intervalMinutes: 12,
      teeBoxes: 18,
      teamsPerTeeBox: 2,
      registeredPlayers: 30,
    ),
    // Tees off in ~30h — inside the 48h window, so its roster is LOCKED. Demos
    // the closed state (pairing preferences still open until the 24h mark).
    Tournament(
      id: 't_riverbend_twilight',
      name: 'Riverbend Twilight Cup',
      clubName: 'Riverbend Golf Club',
      zone: 'Austin, TX',
      format: 'Skins',
      courseName: 'Riverbend Championship Course',
      date: DateTime.now().add(const Duration(hours: 30)),
      firstTeeTime: '5:30 PM',
      teeOff: DateTime.now().add(const Duration(hours: 30)),
      intervalMinutes: 10,
      teeBoxes: 9,
      teamsPerTeeBox: 2,
      registeredPlayers: 16,
      // Skins side game with the handicap-deduction bands set (Stan's addition):
      // low-handicap winners give up a % that's split among winners at 5.6+.
      contests: ContestConfig(
        holePars: ContestConfig.defaultPars(),
        kpHoles: const [3, 7, 11, 16],
        skinsPot: 200,
        kpPot: 100,
        skinsDeductMidPercent: 10,
        skinsDeductPlusPercent: 20,
      ),
    ),
    // A Shotgun Start tournament — the tee sheet places groups on holes, all
    // sharing one start time. Riverbend, so the Club Creator can build it.
    Tournament(
      id: 't_riverbend_shotgun',
      name: 'Riverbend Shotgun Scramble',
      clubName: 'Riverbend Golf Club',
      zone: 'Austin, TX',
      format: 'Scramble',
      courseName: 'Riverbend Championship Course',
      date: _teeOff(6, 8, 0),
      firstTeeTime: '8:00 AM',
      teeOff: _teeOff(6, 8, 0),
      intervalMinutes: 10, // unused for shotgun, but required
      startType: StartType.shotgun,
      teeBoxes: 18,
      teamsPerTeeBox: 3,
      golfCourseEmail: 'proshop@riverbendgolf.example',
      registeredPlayers: 20,
    ),
    // A member-club tournament that's already locked — demos the member-side
    // "Registration closed" state.
    Tournament(
      id: 't_oakmont_medal',
      name: 'Oakmont Monthly Medal',
      clubName: 'Oakmont Hills',
      zone: 'Austin, TX',
      format: 'Stroke Play',
      courseName: 'Oakmont North',
      date: DateTime.now().add(const Duration(hours: 20)),
      firstTeeTime: '7:30 AM',
      teeOff: DateTime.now().add(const Duration(hours: 20)),
      intervalMinutes: 10,
      teeBoxes: 9,
      teamsPerTeeBox: 2,
      registeredPlayers: 44,
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
