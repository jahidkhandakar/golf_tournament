import '../entities/looking_post.dart';

abstract class LookingRepository {
  Future<List<LookingPost>> getLookingPosts();

  /// Gated by [PermissionService.can] at the call site — Free users are
  /// blocked before this is ever reached.
  Future<void> createPost(LookingPost post);
}
