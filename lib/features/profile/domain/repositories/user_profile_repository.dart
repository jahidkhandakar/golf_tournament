import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile> getCurrentUser();

  /// Publish or clear the user's optional global handicap (§ item 6). Pass null
  /// to unpublish it.
}
