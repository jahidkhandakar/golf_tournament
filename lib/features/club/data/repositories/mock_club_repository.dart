import '../../domain/entities/club.dart';
import '../../domain/entities/club_member.dart';
import '../../domain/repositories/club_repository.dart';

/// Hardcoded stand-in for a real API-backed repository. Holds every club;
/// which of them the user belongs to is tracked in PlayController.joinedClubs
/// (seeded {Riverbend, Oakmont}). Club names match the leaderboard players'
/// clubs so the challenge flow lines up.
class MockClubRepository implements ClubRepository {
  static const List<Club> _clubs = [
    Club(
      id: 'c1',
      name: 'Riverbend Golf Club',
      location: 'Austin, TX',
      members: [
        ClubMember(id: 'm1', name: 'Marcus Thompson', handicap: 8.2, isAdmin: true),
        ClubMember(id: 'm2', name: 'Dana Reyes', handicap: 14.6),
        ClubMember(id: 'm3', name: 'Priya Kapoor', handicap: 11.0),
        ClubMember(id: 'm4', name: 'Sam Ortiz', handicap: 19.4),
        ClubMember(id: 'm5', name: 'Erin Walsh', handicap: 6.7),
      ],
    ),
    Club(
      id: 'c2',
      name: 'Oakmont Hills',
      location: 'Round Rock, TX',
      members: [
        ClubMember(id: 'm6', name: 'Erin Walsh', handicap: 2.1, isAdmin: true),
        ClubMember(id: 'm7', name: 'Dana Reyes', handicap: 7.5),
        ClubMember(id: 'm8', name: 'Jordan Blake', handicap: 8.1),
        ClubMember(id: 'm9', name: 'Casey Nguyen', handicap: 9.4),
      ],
    ),
    Club(
      id: 'c3',
      name: 'Pine Valley Muni',
      location: 'Cedar Park, TX',
      members: [
        ClubMember(id: 'm10', name: 'Devon Lee', handicap: 5.2, isAdmin: true),
        ClubMember(id: 'm11', name: 'Sam Ortiz', handicap: 6.8),
        ClubMember(id: 'm12', name: 'Riley Foster', handicap: 10.2),
      ],
    ),
    Club(
      id: 'c4',
      name: 'Hill Country Club',
      location: 'Fredericksburg, TX',
      members: [
        ClubMember(id: 'm13', name: 'Jordan Blake', handicap: 8.1, isAdmin: true),
        ClubMember(id: 'm14', name: 'Alex Rivera', handicap: 3.7),
      ],
    ),
    Club(
      id: 'c5',
      name: 'Lakeside Links',
      location: 'Lakeside, TX',
      members: [
        ClubMember(id: 'm15', name: 'Casey Nguyen', handicap: 9.4, isAdmin: true),
        ClubMember(id: 'm16', name: 'Taylor Brooks', handicap: 11.6),
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
