import '../../../../core/user/user_tier.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';

class MockUserProfileRepository implements UserProfileRepository {
  static const UserProfile _currentUser = UserProfile(
    name: 'John Doe',
    tier: UserTier.free,
    handicap: 14.2,
  );

  @override
  Future<UserProfile> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentUser;
  }
}
