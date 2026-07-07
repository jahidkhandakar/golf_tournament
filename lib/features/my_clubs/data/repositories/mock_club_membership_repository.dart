import '../../domain/entities/club_membership.dart';
import '../../domain/repositories/club_membership_repository.dart';

class MockClubMembershipRepository implements ClubMembershipRepository {
  static const List<ClubMembership> _memberships = [
    ClubMembership(
      id: 'c1',
      clubName: 'Riverbend Golf Club',
      location: 'Austin, TX',
      memberCount: 5,
      role: ClubRole.member,
      isHomeClub: true,
    ),
    ClubMembership(
      id: 'c2',
      clubName: 'Oakmont Hills',
      location: 'Round Rock, TX',
      memberCount: 212,
      role: ClubRole.member,
      isHomeClub: false,
    ),
  ];

  @override
  Future<List<ClubMembership>> getMyClubs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _memberships;
  }
}
