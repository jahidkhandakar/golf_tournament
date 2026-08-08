import 'entities/contest_config.dart';
import 'entities/player_score.dart';

/// One hole's skin outcome after the tournament-wide comparison.
class SkinResult {
  const SkinResult({
    required this.hole,
    required this.winner,
    required this.winningScore,
    required this.par,
    required this.wonWithPar,
    required this.value,
    this.deductPercent = 0,
  });

  final int hole;
  final String winner;
  final int winningScore;
  final int par;

  /// True when the skin was taken by a lone par on an open hole rather than a
  /// birdie or better.
  final bool wonWithPar;

  /// Dollar value under the tournament's payout mode, after any handicap band
  /// deduction and redistribution. Recomputed live as scores come in, so
  /// values shift until results go final.
  final double value;

  /// The deduction percent applied to this winner's skin, 0 when none.
  final int deductPercent;
}

/// The skins engine. Pool is tournament wide: every player competes on every
/// hole regardless of group.
///
/// A hole is won when exactly one player holds the best score on it and that
/// score is birdie or better (the default rule). A lone par can take a hole
/// only when nobody made birdie or better on it and exactly one player in the
/// whole tournament made par. Everything else leaves the hole open.
///
/// Payouts follow [ContestConfig.payoutMode]:
///   poolSplit: skinsPot divided by the number of skins actually won.
///   carryover: each hole is worth skinsPot / 18; an open hole rolls its value
///              into the next hole; value left after hole 18 splits among the
///              winners already on the board.
class Skins {
  Skins._();

  static List<SkinResult> compute(
    List<PlayerScore> allScores,
    ContestConfig config, {
    Map<String, double> handicaps = const {},
    int? deductMidPercent,
    int? deductPlusPercent,
  }) {
    final midPct = deductMidPercent ?? config.skinsDeductMidPercent;
    final plusPct = deductPlusPercent ?? config.skinsDeductPlusPercent;
    final winners = <int, ({String player, int score, bool par})>{};

    for (var hole = 1; hole <= 18; hole++) {
      final par = config.parFor(hole);
      final entries = <({String player, int score})>[];
      for (final s in allScores) {
        // Opted-out players and (when excluded) guests are invisible to the
        // skins engine: they can neither win nor cut a hole.
        if (!config.participatesInSkins(s.playerName)) continue;
        final holes = s.holes;
        if (holes == null || holes.length < hole) continue;
        final v = holes[hole - 1];
        if (v > 0) entries.add((player: s.playerName, score: v));
      }
      if (entries.isEmpty) continue;

      final best = entries.map((e) => e.score).reduce((a, b) => a < b ? a : b);
      final holders = entries.where((e) => e.score == best).toList();

      if (best <= par - 1 && holders.length == 1) {
        winners[hole] = (player: holders.first.player, score: best, par: false);
        continue;
      }
      // Lone par takes an open hole: nobody at birdie or better, exactly one
      // par in the whole field.
      if (best == par) {
        final pars = entries.where((e) => e.score == par).toList();
        if (pars.length == 1) {
          winners[hole] = (player: pars.first.player, score: par, par: true);
        }
      }
    }

    if (winners.isEmpty) return const [];

    final values = <int, double>{};
    if (config.payoutMode == PayoutMode.poolSplit) {
      final each = config.skinsPot / winners.length;
      for (final h in winners.keys) {
        values[h] = each;
      }
    } else {
      final nominal = config.skinsPot / 18;
      var carried = 0.0;
      for (var hole = 1; hole <= 18; hole++) {
        if (winners.containsKey(hole)) {
          values[hole] = nominal + carried;
          carried = 0.0;
        } else {
          carried += nominal;
        }
      }
      if (carried > 0 && winners.isNotEmpty) {
        final extra = carried / winners.length;
        for (final h in winners.keys) {
          values[h] = (values[h] ?? 0) + extra;
        }
      }
    }

    // Handicap band deduction. Winners at a club handicap of 5.6 and above
    // keep their full skin. Winners from 0 to 5.5 give up the mid band
    // percent; plus handicap winners (below zero) give up the plus band
    // percent. Everything deducted goes back into the purse and splits evenly
    // across the skins held by winners at 5.6 and above. When no winner sits
    // at 5.6 or above there is nobody to receive the money, so no deduction
    // is taken and everyone keeps their base value.
    final deducts = <int, int>{};
    if (midPct > 0 || plusPct > 0) {
      double pool = 0;
      final eligibleHoles = <int>[];
      for (final e in winners.entries) {
        final hcp = handicaps[e.value.player];
        if (hcp == null || hcp >= 5.6) {
          eligibleHoles.add(e.key);
          continue;
        }
        final pct = hcp < 0 ? plusPct : midPct;
        if (pct <= 0) {
          eligibleHoles.add(e.key);
          continue;
        }
        deducts[e.key] = pct;
        final v = values[e.key] ?? 0;
        final taken = v * pct / 100;
        pool += taken;
        values[e.key] = v - taken;
      }
      if (eligibleHoles.isEmpty) {
        // Nobody at 5.6 or above to receive the pool: undo the deduction.
        for (final e in deducts.entries) {
          final v = values[e.key] ?? 0;
          values[e.key] = v / (1 - e.value / 100);
        }
        deducts.clear();
      } else if (pool > 0) {
        final share = pool / eligibleHoles.length;
        for (final h in eligibleHoles) {
          values[h] = (values[h] ?? 0) + share;
        }
      }
    }

    final results = winners.entries
        .map((e) => SkinResult(
              hole: e.key,
              winner: e.value.player,
              winningScore: e.value.score,
              par: config.parFor(e.key),
              wonWithPar: e.value.par,
              value: values[e.key] ?? 0,
              deductPercent: deducts[e.key] ?? 0,
            ))
        .toList()
      ..sort((a, b) => a.hole.compareTo(b.hole));
    return results;
  }

  /// Per-winner KP or long-drive payouts for the recorded [winners] under the
  /// tournament's payout mode. [eligibleHoles] is the designated hole list in
  /// course order. Returns hole -> dollar value for won holes.
  static Map<int, double> contestValues({
    required List<int> eligibleHoles,
    required Set<int> wonHoles,
    required int pot,
    required PayoutMode mode,
  }) {
    final won = eligibleHoles.where(wonHoles.contains).toList();
    if (won.isEmpty || pot <= 0) return {};
    final values = <int, double>{};
    if (mode == PayoutMode.poolSplit) {
      final each = pot / won.length;
      for (final h in won) {
        values[h] = each;
      }
    } else {
      final nominal = pot / eligibleHoles.length;
      var carried = 0.0;
      for (final h in eligibleHoles) {
        if (wonHoles.contains(h)) {
          values[h] = nominal + carried;
          carried = 0.0;
        } else {
          carried += nominal;
        }
      }
      if (carried > 0) {
        final extra = carried / won.length;
        for (final h in won) {
          values[h] = (values[h] ?? 0) + extra;
        }
      }
    }
    return values;
  }

  /// The single lowest-gross winner, or null on a tie / no scores. Kept for
  /// the gross-only fallback when no by-hole data exists.
  static String? grossSkin(List<PlayerScore> scores) {
    final scored = scores.where((s) => s.gross != null).toList()
      ..sort((a, b) => a.gross!.compareTo(b.gross!));
    if (scored.isEmpty) return null;
    if (scored.length > 1 && scored[0].gross == scored[1].gross) return null;
    return scored.first.playerName;
  }
}
