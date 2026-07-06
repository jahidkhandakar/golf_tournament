import '../../domain/entities/challenge.dart';
import '../../domain/repositories/challenge_repository.dart';

class MockChallengeRepository implements ChallengeRepository {
  static final List<Challenge> _challenges = [
    Challenge(
      id: 'ch1',
      opponentName: 'Devon Lee',
      date: DateTime.now().subtract(const Duration(days: 5)),
      status: ChallengeStatus.won,
      resultSummary: '3 & 2',
    ),
    Challenge(
      id: 'ch2',
      opponentName: 'Casey Nguyen',
      date: DateTime.now().subtract(const Duration(days: 14)),
      status: ChallengeStatus.lost,
      resultSummary: '1 down',
    ),
    Challenge(
      id: 'ch3',
      opponentName: 'Jordan Blake',
      date: DateTime.now().add(const Duration(days: 2)),
      status: ChallengeStatus.pending,
    ),
  ];

  @override
  Future<List<Challenge>> getChallengeHistory() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _challenges;
  }
}
