import '../../../../core/user/user_tier.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';

class MockUserProfileRepository implements UserProfileRepository {
  // The logged-in user. Their club + current tournament/course are mirrored
  // in PlayController's seed so the Top 50 challenge conditions line up with
  // this identity out of the box.
  UserProfile _currentUser = const UserProfile(
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

  @override
  Future<UserProfile> updateGlobalHandicap(double? value) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = UserProfile(
      name: _currentUser.name,
      tier: _currentUser.tier,
      clubHandicap: _currentUser.clubHandicap,
      globalHandicap: value,
      homeClub: _currentUser.homeClub,
      currentTournament: _currentUser.currentTournament,
      currentCourse: _currentUser.currentCourse,
    );
    return _currentUser;
  }
}
