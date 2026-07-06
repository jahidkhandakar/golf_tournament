import '../entities/looking_post.dart';

abstract class LookingRepository {
  Future<List<LookingPost>> getLookingPosts();
}
