import '../../domain/entities/looking_post.dart';
import '../../domain/repositories/looking_repository.dart';

/// Hardcoded stand-in for a real API-backed repository.
class MockLookingRepository implements LookingRepository {
  static final List<LookingPost> _posts = [
    LookingPost(
      id: 'l1',
      playerName: 'Sam Ortiz',
      location: 'Austin, TX',
      availableDates: ['Sat Jul 11', 'Sun Jul 12'],
      preferredFormats: ['Stroke Play', 'Scramble'],
      note: 'Looking for a relaxed foursome, mid-handicap friendly.',
    ),
    LookingPost(
      id: 'l2',
      playerName: 'Erin Walsh',
      location: 'Round Rock, TX',
      availableDates: ['Fri Jul 10'],
      preferredFormats: ['Best Ball'],
      note: 'Free after 3pm, happy to join any group nearby.',
    ),
    LookingPost(
      id: 'l3',
      playerName: 'Devon Lee',
      location: 'Cedar Park, TX',
      availableDates: ['Sat Jul 11', 'Wed Jul 15'],
      preferredFormats: ['Stroke Play'],
      note: 'New to the area, looking to meet other golfers.',
    ),
  ];

  @override
  Future<List<LookingPost>> getLookingPosts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _posts;
  }

  @override
  Future<void> createPost(LookingPost post) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _posts.insert(0, post);
  }
}
