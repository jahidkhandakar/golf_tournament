import '../entities/round.dart';

abstract class RoundRepository {
  Future<List<Round>> getRoundHistory();
}
