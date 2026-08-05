import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/leaderboard_repository.dart';

/// Hardcoded stand-in for the real ranking engine (backend/Phase 2).
/// The ladder is ordered by [LeaderboardEntry.position] (1 = top); challenge
/// results move players by position (see ladder_movement.dart). The logged-in
/// user (Jahid) sits at position 6 so beating someone above them demonstrates
/// the take-their-spot mechanic.
///
/// Clubs/tournaments are assigned so both challenge paths are demoable against
/// the user's clubs ({Riverbend, Oakmont}): players in those clubs let you join
/// their tournament directly, while Pine Valley / Hill Country / Lakeside
/// players require joining the club first.
class MockLeaderboardRepository implements LeaderboardRepository {
  static const List<LeaderboardEntry> _entries = [
    LeaderboardEntry(
      position: 1,
      playerName: 'Erin Walsh',
      roundsPlayed: 34,
      distanceMiles: 12,
      clubName: 'Oakmont Hills',
      tournamentId: 't_oakmont',
      tournamentName: 'Oakmont Summer Open',
      courseName: 'Oakmont North',
      teeTime: '8:00 PM',
    ),
    LeaderboardEntry(
      position: 2,
      playerName: 'Marcus Thompson',
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
      position: 3,
      playerName: 'Alex Rivera',
      roundsPlayed: 31,
      distanceMiles: 30,
      clubName: 'Riverbend Golf Club',
      tournamentId: 't_riverbend',
      tournamentName: 'Riverbend Championship',
      courseName: 'Riverbend West Course',
      teeTime: '8:20 AM',
    ),
    LeaderboardEntry(
      position: 4,
      playerName: 'Priya Kapoor',
      roundsPlayed: 28,
      distanceMiles: 40,
      clubName: 'Riverbend Golf Club',
      tournamentId: 't_riverbend',
      tournamentName: 'Riverbend Championship',
      courseName: 'Riverbend Championship Course',
      teeTime: '7:40 AM',
    ),
    LeaderboardEntry(
      position: 5,
      playerName: 'Devon Lee',
      roundsPlayed: 22,
      distanceMiles: 55,
      clubName: 'Pine Valley Muni',
      tournamentId: 't_pinevalley',
      tournamentName: 'Pine Valley Classic',
      courseName: 'Pine Valley East',
      teeTime: '1:00 PM',
    ),
    // The logged-in user — starts mid-ladder so Marcus (2) and Priya (4), who
    // share their tournament + course, are directly challengeable from above.
    LeaderboardEntry(
      position: 6,
      playerName: 'Jahid',
      isCurrentUser: true,
      roundsPlayed: 24,
      distanceMiles: 0,
      clubName: 'Riverbend Golf Club',
      tournamentId: 't_riverbend',
      tournamentName: 'Riverbend Championship',
      courseName: 'Riverbend Championship Course',
      teeTime: '7:10 AM',
    ),
    LeaderboardEntry(
      position: 7,
      playerName: 'Sam Ortiz',
      roundsPlayed: 19,
      distanceMiles: 58,
      clubName: 'Pine Valley Muni',
      tournamentId: 't_pinevalley',
      tournamentName: 'Pine Valley Classic',
      courseName: 'Pine Valley East',
      teeTime: '1:00 PM',
    ),
    LeaderboardEntry(
      position: 8,
      playerName: 'Dana Reyes',
      roundsPlayed: 26,
      distanceMiles: 62,
      clubName: 'Oakmont Hills',
      tournamentId: 't_oakmont',
      tournamentName: 'Oakmont Summer Open',
      courseName: 'Oakmont North',
      teeTime: '8:00 PM',
    ),
    LeaderboardEntry(
      position: 9,
      playerName: 'Jordan Blake',
      roundsPlayed: 15,
      distanceMiles: 70,
      clubName: 'Hill Country Club',
      tournamentId: 't_hillcountry',
      tournamentName: 'Hill Country Open',
      courseName: 'Hill Country Ridge',
      teeTime: '9:00 AM',
    ),
    LeaderboardEntry(
      position: 10,
      playerName: 'Casey Nguyen',
      roundsPlayed: 18,
      distanceMiles: 95,
      clubName: 'Lakeside Links',
      tournamentId: 't_lakeside',
      tournamentName: 'Lakeside Invitational',
      courseName: 'Lakeside South',
      teeTime: '10:30 AM',
    ),
    LeaderboardEntry(
      position: 11,
      playerName: 'Riley Foster',
      roundsPlayed: 12,
      distanceMiles: 110,
      clubName: 'Pine Valley Muni',
      tournamentId: 't_pinevalley',
      tournamentName: 'Pine Valley Classic',
      courseName: 'Pine Valley East',
      teeTime: '1:00 PM',
    ),
    LeaderboardEntry(
      position: 12,
      playerName: 'Taylor Brooks',
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
