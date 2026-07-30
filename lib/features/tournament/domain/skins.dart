import 'entities/player_score.dart';

/// The skins calculator (§6). It runs automatically once scores are in for a
/// skins-format tournament.
///
/// [holeSkins] uses by-hole data: on each hole, the strictly-lowest score wins
/// that hole's skin; a tie carries (no winner that hole). [grossSkin] is the
/// gross-only fallback — the single strictly-lowest total wins one skin.
class Skins {
  Skins._();

  /// hole number (1-based) -> winning player, only for holes with a clear winner.
  static Map<int, String> holeSkins(List<PlayerScore> scores) {
    final withHoles = scores.where((s) => s.holes != null && s.holes!.isNotEmpty).toList();
    if (withHoles.isEmpty) return {};
    final holeCount = withHoles.first.holes!.length;
    final result = <int, String>{};

    for (var h = 0; h < holeCount; h++) {
      int? best;
      String? winner;
      var tie = false;
      for (final s in withHoles) {
        if (h >= s.holes!.length) continue;
        final v = s.holes![h];
        if (best == null || v < best) {
          best = v;
          winner = s.playerName;
          tie = false;
        } else if (v == best) {
          tie = true;
        }
      }
      if (winner != null && !tie) result[h + 1] = winner;
    }
    return result;
  }

  /// The single lowest-gross winner, or null on a tie / no scores.
  static String? grossSkin(List<PlayerScore> scores) {
    final scored = scores.where((s) => s.gross != null).toList()
      ..sort((a, b) => a.gross!.compareTo(b.gross!));
    if (scored.isEmpty) return null;
    if (scored.length > 1 && scored[0].gross == scored[1].gross) return null;
    return scored.first.playerName;
  }
}
