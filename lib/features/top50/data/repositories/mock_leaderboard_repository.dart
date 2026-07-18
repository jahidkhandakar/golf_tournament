import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/leaderboard_repository.dart';

/// Hardcoded stand-in for the real ranking engine (backend/Phase 2).
/// Entries are ordered best-to-worst by handicap; the page filters them by
/// the current search radius and assigns display ranks after filtering.
///
/// Clubs/tournaments are assigned so both challenge paths are demoable
/// against the user's clubs ({Riverbend, Oakmont}): players in those clubs
/// let you join their tournament directly, while Pine Valley / Hill Country
/// / Lakeside players require joining the club first.
class MockLeaderboardRepository implements LeaderboardRepository {
  static const List<LeaderboardEntry> _entries = [
    LeaderboardEntry(
      playerName: 'Erin Walsh',
      handicap: 2.1,
      roundsPlayed: 34,
      distanceMiles: 12,
      clubName: 'Oakmont Hills',
      tournamentId: 't_oakmont',
      tournamentName: 'Oakmont Summer Open',
      courseName: 'Oakmont North',
      teeTime: '8:00 PM',
    ),
    LeaderboardEntry(
      playerName: 'Marcus Thompson',
      handicap: 3.4,
      roundsPlayed: 41,
      distanceMiles: 25,
      clubName: 'Riverbend Golf Club',
      tournamentId: 't_riverbend',
      tournamentName: 'Riverbend Championship',
      courseName: 'Riverbend Championship Course',
      teeTime: '7:40 AM',
    ),
    // Same tournament as Marcus/Priya (t_riverbend) but a DIFFERENT course —
    // used to prove the "same tournament AND same golf course" rule: joining
    // the Championship Course won't unlock a challenge against this player.
    LeaderboardEntry(
      playerName: 'Alex Rivera',
      handicap: 3.7,
      roundsPlayed: 31,
      distanceMiles: 30,
      clubName: 'Riverbend Golf Club',
      tournamentId: 't_riverbend',
      tournamentName: 'Riverbend Championship',
      courseName: 'Riverbend West Course',
      teeTime: '8:20 AM',
    ),
    LeaderboardEntry(
      playerName: 'Priya Kapoor',
      handicap: 4.0,
      roundsPlayed: 28,
      distanceMiles: 40,
      clubName: 'Riverbend Golf Club',
      tournamentId: 't_riverbend',
      tournamentName: 'Riverbend Championship',
      courseName: 'Riverbend Championship Course',
      teeTime: '7:40 AM',
    ),
    LeaderboardEntry(
      playerName: 'Devon Lee',
      handicap: 5.2,
      roundsPlayed: 22,
      distanceMiles: 55,
      clubName: 'Pine Valley Muni',
      tournamentId: 't_pinevalley',
      tournamentName: 'Pine Valley Classic',
      courseName: 'Pine Valley East',
      teeTime: '1:00 PM',
    ),
    LeaderboardEntry(
      playerName: 'Sam Ortiz',
      handicap: 6.8,
      roundsPlayed: 19,
      distanceMiles: 58,
      clubName: 'Pine Valley Muni',
      tournamentId: 't_pinevalley',
      tournamentName: 'Pine Valley Classic',
      courseName: 'Pine Valley East',
      teeTime: '1:00 PM',
    ),
    LeaderboardEntry(
      playerName: 'Dana Reyes',
      handicap: 7.5,
      roundsPlayed: 26,
      distanceMiles: 62,
      clubName: 'Oakmont Hills',
      tournamentId: 't_oakmont',
      tournamentName: 'Oakmont Summer Open',
      courseName: 'Oakmont North',
      teeTime: '8:00 PM',
    ),
    LeaderboardEntry(
      playerName: 'Jordan Blake',
      handicap: 8.1,
      roundsPlayed: 15,
      distanceMiles: 70,
      clubName: 'Hill Country Club',
      tournamentId: 't_hillcountry',
      tournamentName: 'Hill Country Open',
      courseName: 'Hill Country Ridge',
      teeTime: '9:00 AM',
    ),
    LeaderboardEntry(
      playerName: 'Casey Nguyen',
      handicap: 9.4,
      roundsPlayed: 18,
      distanceMiles: 95,
      clubName: 'Lakeside Links',
      tournamentId: 't_lakeside',
      tournamentName: 'Lakeside Invitational',
      courseName: 'Lakeside South',
      teeTime: '10:30 AM',
    ),
    LeaderboardEntry(
      playerName: 'Riley Foster',
      handicap: 10.2,
      roundsPlayed: 12,
      distanceMiles: 110,
      clubName: 'Pine Valley Muni',
      tournamentId: 't_pinevalley',
      tournamentName: 'Pine Valley Classic',
      courseName: 'Pine Valley East',
      teeTime: '1:00 PM',
    ),
    LeaderboardEntry(
      playerName: 'Taylor Brooks',
      handicap: 11.6,
      roundsPlayed: 20,
      distanceMiles: 130,
      clubName: 'Lakeside Links',
      tournamentId: 't_lakeside',
      tournamentName: 'Lakeside Invitational',
      courseName: 'Lakeside South',
      teeTime: '10:30 AM',
    ),
  ];

  @override
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _entries;
  }
}
