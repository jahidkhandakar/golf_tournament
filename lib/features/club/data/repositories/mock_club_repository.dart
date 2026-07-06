import '../../domain/entities/club.dart';
import '../../domain/entities/club_member.dart';
import '../../domain/repositories/club_repository.dart';

/// Hardcoded stand-in for a real API-backed repository. Returns a populated
/// club by default so the Feed/Results/Chat/Marketplace/Gallery tabs have
/// something to render — real "does this user have a club" data comes later.
class MockClubRepository implements ClubRepository {
  static final Club _club = Club(
    id: 'c1',
    name: 'Riverbend Golf Club',
    members: const [
      ClubMember(id: 'm1', name: 'Marcus Thompson', handicap: 8.2, isAdmin: true),
      ClubMember(id: 'm2', name: 'Dana Reyes', handicap: 14.6),
      ClubMember(id: 'm3', name: 'Priya Kapoor', handicap: 11.0),
      ClubMember(id: 'm4', name: 'Sam Ortiz', handicap: 19.4),
      ClubMember(id: 'm5', name: 'Erin Walsh', handicap: 6.7),
    ],
  );

  @override
  Future<Club?> getMyClub() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _club;
  }
}
