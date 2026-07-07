import '../entities/club_membership.dart';

abstract class ClubMembershipRepository {
  Future<List<ClubMembership>> getMyClubs();
}
