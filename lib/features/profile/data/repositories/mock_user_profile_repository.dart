import '../../../../core/user/user_tier.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';

class MockUserProfileRepository implements UserProfileRepository {
  // The logged-in user. Their club + current tournament/course are mirrored
  // in PlayController's seed so the Top 50 challenge conditions line up with
  // this identity out of the box.
  static const UserProfile _currentUser = UserProfile(
    name: 'Jahid',
    tier: UserTier.free,
    clubHandicap: 7.4,
    globalHandicap: 6.9,
    homeClub: 'Riverbend Golf Club',
    currentTournament: 'Riverbend Championship',
    currentCourse: 'Riverbend Championship Course',
  );

  @override
  Future<UserProfile> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentUser;
  }
}
