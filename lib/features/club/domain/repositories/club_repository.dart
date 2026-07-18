import '../entities/club.dart';

abstract class ClubRepository {
  /// Every club, joined or not — My Clubs splits them into "your clubs" vs
  /// "discover" using PlayController.joinedClubs.
  Future<List<Club>> getAllClubs();

  /// A single club by id (null if it doesn't exist).
  Future<Club?> getClub(String id);
}
