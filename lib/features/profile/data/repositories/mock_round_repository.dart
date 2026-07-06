import '../../domain/entities/round.dart';
import '../../domain/repositories/round_repository.dart';

class MockRoundRepository implements RoundRepository {
  static final List<Round> _rounds = [
    Round(
      id: 'r1',
      courseName: 'Riverbend Championship Course',
      date: DateTime.now().subtract(const Duration(days: 3)),
      format: 'Stroke Play',
      score: 82,
      toPar: 10,
    ),
    Round(
      id: 'r2',
      courseName: 'Oakmont North',
      date: DateTime.now().subtract(const Duration(days: 10)),
      format: 'Scramble',
      score: 76,
      toPar: 4,
    ),
    Round(
      id: 'r3',
      courseName: 'Pine Valley East',
      date: DateTime.now().subtract(const Duration(days: 21)),
      format: 'Best Ball',
      score: 79,
      toPar: 7,
    ),
    Round(
      id: 'r4',
      courseName: 'Riverbend Championship Course',
      date: DateTime.now().subtract(const Duration(days: 35)),
      format: 'Stroke Play',
      score: 85,
      toPar: 13,
    ),
  ];

  @override
  Future<List<Round>> getRoundHistory() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _rounds;
  }
}
