import '../../domain/entities/player_score.dart';
import '../../domain/entities/scorecard.dart';
import '../../domain/repositories/scorecard_repository.dart';

/// In-memory scorecard store, one card per tournament, kept for the session.
class MockScorecardRepository implements ScorecardRepository {
  final Map<String, Scorecard> _cards = {};

  Future<T> _delayed<T>(T value) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return value;
  }

  @override
  Future<Scorecard> load(String tournamentId, List<String> players) {
    final existing = _cards[tournamentId];
    if (existing != null) return _delayed(existing);
    final card = Scorecard(
      tournamentId: tournamentId,
      scores: [for (final p in players) PlayerScore(playerName: p)],
    );
    _cards[tournamentId] = card;
    return _delayed(card);
  }

  @override
  Future<Scorecard?> getIfSubmitted(String tournamentId) {
    final card = _cards[tournamentId];
    return _delayed(card != null && card.submitted ? card : null);
  }

  @override
  Future<Scorecard> submit(String tournamentId, List<PlayerScore> scores) {
    final card = Scorecard(tournamentId: tournamentId, scores: scores, submitted: true);
    _cards[tournamentId] = card;
    return _delayed(card);
  }
}
