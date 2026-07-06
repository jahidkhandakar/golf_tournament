import '../entities/club.dart';

abstract class ClubRepository {
  /// Returns `null` when the current user has no club yet.
  Future<Club?> getMyClub();
}
