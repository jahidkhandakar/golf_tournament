import '../entities/player_score.dart';
import '../entities/scorecard.dart';

/// Scorecard entry (§6). A Club Creator / sub-admin loads the card for a
/// tournament's players, then submits the final scores — which (in production)
/// triggers the Handicap, Top 50, and Club Leaderboard engines.
abstract class ScorecardRepository {
  /// Loads the saved scorecard, or a fresh one seeded with [players].
  Future<Scorecard> load(String tournamentId, List<String> players);

  /// The submitted scorecard for this tournament, or null if scoring isn't in
  /// yet — used to swap the tournament page over to results.
  Future<Scorecard?> getIfSubmitted(String tournamentId);

  /// Persists the final scores and marks the card submitted.
  Future<Scorecard> submit(String tournamentId, List<PlayerScore> scores);
}
