import '../../domain/entities/club.dart';
import '../../domain/entities/club_member.dart';
import '../../domain/repositories/club_repository.dart';

/// Hardcoded stand-in for a real API-backed repository. Holds every club;
/// which of them the user belongs to is tracked in PlayController.joinedClubs
/// (seeded {Riverbend, Oakmont}).
///
/// Leaderboard positions are seeded ONCE from handicap order among each club's
/// eligible members (opted in + 3+ scored rounds). After seeding they are stored
/// on the member and only move through challenges — the leaderboard tab sorts by
/// the stored position, never by handicap.
class MockClubRepository implements ClubRepository {
  final List<Club> _clubs = _seed();

  static List<Club> _seed() => _raw.map((c) => c.withMembers(_seedPositions(c.members))).toList();

  /// Assigns [ClubMember.leaderboardPosition] 1..n by handicap order to the
  /// eligible members; leaves ineligible members unranked.
  static List<ClubMember> _seedPositions(List<ClubMember> members) {
    final eligible = members.where((m) => m.leaderboardOptedIn && m.roundsPlayed >= 3).toList()
      ..sort((a, b) => a.clubHandicap.compareTo(b.clubHandicap));
    final positionById = {for (var i = 0; i < eligible.length; i++) eligible[i].id: i + 1};
    return [for (final m in members) m.copyWith(leaderboardPosition: positionById[m.id])];
  }

  static const List<Club> _raw = [
    Club(
      id: 'c1',
      name: 'Riverbend Golf Club',
      location: 'Austin, TX',
      members: [
        ClubMember(id: 'm1', name: 'Marcus Thompson', clubHandicap: 8.2, isAdmin: true),
        ClubMember(id: 'm2', name: 'Dana Reyes', clubHandicap: 14.6),
        ClubMember(id: 'm3', name: 'Priya Kapoor', clubHandicap: 11.0),
        // Not established yet (under 3 scored rounds) — excluded from ranking.
        ClubMember(id: 'm4', name: 'Sam Ortiz', clubHandicap: 19.4, roundsPlayed: 1),
        ClubMember(id: 'm5', name: 'Erin Walsh', clubHandicap: 6.7),
        ClubMember(id: 'm17', name: 'Jordan Blake', clubHandicap: 8.1),
        ClubMember(id: 'm18', name: 'Casey Nguyen', clubHandicap: 9.4),
        ClubMember(id: 'm19', name: 'Riley Foster', clubHandicap: 10.2),
        ClubMember(id: 'm20', name: 'Alex Rivera', clubHandicap: 3.7),
        // Opted out — excluded from ranking.
        ClubMember(id: 'm21', name: 'Taylor Brooks', clubHandicap: 11.6, leaderboardOptedIn: false),
      ],
    ),
    Club(
      id: 'c2',
      name: 'Oakmont Hills',
      location: 'Round Rock, TX',
      members: [
        ClubMember(id: 'm6', name: 'Erin Walsh', clubHandicap: 2.1, isAdmin: true),
        ClubMember(id: 'm7', name: 'Dana Reyes', clubHandicap: 7.5),
        ClubMember(id: 'm8', name: 'Jordan Blake', clubHandicap: 8.1),
        ClubMember(id: 'm9', name: 'Casey Nguyen', clubHandicap: 9.4),
      ],
    ),
    Club(
      id: 'c3',
      name: 'Pine Valley Muni',
      location: 'Cedar Park, TX',
      members: [
        ClubMember(id: 'm10', name: 'Devon Lee', clubHandicap: 5.2, isAdmin: true),
        ClubMember(id: 'm11', name: 'Sam Ortiz', clubHandicap: 6.8),
        ClubMember(id: 'm12', name: 'Riley Foster', clubHandicap: 10.2),
      ],
    ),
    Club(
      id: 'c4',
      name: 'Hill Country Club',
      location: 'Fredericksburg, TX',
      members: [
        ClubMember(id: 'm13', name: 'Jordan Blake', clubHandicap: 8.1, isAdmin: true),
        ClubMember(id: 'm14', name: 'Alex Rivera', clubHandicap: 3.7),
      ],
    ),
    Club(
      id: 'c5',
      name: 'Lakeside Links',
      location: 'Lakeside, TX',
      members: [
        ClubMember(id: 'm15', name: 'Casey Nguyen', clubHandicap: 9.4, isAdmin: true),
        ClubMember(id: 'm16', name: 'Taylor Brooks', clubHandicap: 11.6),
      ],
    ),
  ];

  @override
  Future<List<Club>> getAllClubs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _clubs;
  }

  @override
  Future<Club?> getClub(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (final club in _clubs) {
      if (club.id == id) return club;
    }
    return null;
  }
}
