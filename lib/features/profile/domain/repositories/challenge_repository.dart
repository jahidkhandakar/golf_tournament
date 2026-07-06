import '../entities/challenge.dart';

abstract class ChallengeRepository {
  Future<List<Challenge>> getChallengeHistory();
}
