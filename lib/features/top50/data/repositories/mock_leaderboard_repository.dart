import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/leaderboard_repository.dart';

/// Hardcoded stand-in for the real ranking engine (backend/Phase 2).
class MockLeaderboardRepository implements LeaderboardRepository {
  static const List<LeaderboardEntry> _entries = [
    LeaderboardEntry(rank: 1, playerName: 'Erin Walsh', handicap: 2.1, roundsPlayed: 34),
    LeaderboardEntry(rank: 2, playerName: 'Marcus Thompson', handicap: 3.4, roundsPlayed: 41),
    LeaderboardEntry(rank: 3, playerName: 'Priya Kapoor', handicap: 4.0, roundsPlayed: 28),
    LeaderboardEntry(rank: 4, playerName: 'Devon Lee', handicap: 5.2, roundsPlayed: 22),
    LeaderboardEntry(rank: 5, playerName: 'Sam Ortiz', handicap: 6.8, roundsPlayed: 19),
    LeaderboardEntry(rank: 6, playerName: 'Dana Reyes', handicap: 7.5, roundsPlayed: 26),
    LeaderboardEntry(rank: 7, playerName: 'Jordan Blake', handicap: 8.1, roundsPlayed: 15),
    LeaderboardEntry(rank: 8, playerName: 'Casey Nguyen', handicap: 9.4, roundsPlayed: 18),
    LeaderboardEntry(rank: 9, playerName: 'Riley Foster', handicap: 10.2, roundsPlayed: 12),
    LeaderboardEntry(rank: 10, playerName: 'Taylor Brooks', handicap: 11.6, roundsPlayed: 20),
  ];

  @override
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _entries;
  }
}
