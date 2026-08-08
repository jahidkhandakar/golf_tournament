import 'package:flutter_test/flutter_test.dart';
import 'package:ggw_connect/features/tournament/domain/entities/contest_config.dart';
import 'package:ggw_connect/features/tournament/domain/entities/player_score.dart';
import 'package:ggw_connect/features/tournament/domain/skins.dart';

/// Guards the participation rule: opted-out players and (when excluded) guests
/// are invisible to the skins engine — they cannot win a hole and cannot cut
/// one. Mirrors backend spec §4 (per-player participation) and §5 (guests).
void main() {
  ContestConfig config({
    Set<String> skinsOptOut = const {},
    Set<String> guests = const {},
    bool guestsInSideGames = false,
  }) =>
      ContestConfig(
        holePars: List<int>.filled(18, 4),
        skinsPot: 180,
        payoutMode: PayoutMode.poolSplit,
        skinsOptOut: skinsOptOut,
        guests: guests,
        guestsInSideGames: guestsInSideGames,
      );

  // A single played hole (hole 1), rest empty (0 = not entered).
  PlayerScore onHole1(String name, int strokes) {
    final holes = List<int>.filled(18, 0);
    holes[0] = strokes;
    return PlayerScore(playerName: name, holes: holes);
  }

  SkinResult? hole1(List<SkinResult> results) {
    for (final r in results) {
      if (r.hole == 1) return r;
    }
    return null;
  }

  test('baseline: lone birdie beats a par', () {
    final results = Skins.compute(
      [onHole1('Ana', 3), onHole1('Ben', 4)],
      config(),
    );
    final h1 = hole1(results);
    expect(h1, isNotNull);
    expect(h1!.winner, 'Ana');
    expect(h1.wonWithPar, isFalse);
  });

  test('opted-out player cannot win — hole passes to the lone par', () {
    final results = Skins.compute(
      [onHole1('Ana', 3), onHole1('Ben', 4)],
      config(skinsOptOut: {'Ana'}),
    );
    final h1 = hole1(results);
    expect(h1, isNotNull);
    expect(h1!.winner, 'Ben');
    expect(h1.wonWithPar, isTrue);
  });

  test('opted-out player cannot cut — the other lone birdie wins', () {
    // Both birdie: normally a tie (no skin). Opting one out leaves a lone
    // birdie, so the hole is won rather than cut.
    final tie = Skins.compute([onHole1('Ana', 3), onHole1('Ben', 3)], config());
    expect(hole1(tie), isNull);

    final results = Skins.compute(
      [onHole1('Ana', 3), onHole1('Ben', 3)],
      config(skinsOptOut: {'Ben'}),
    );
    expect(hole1(results)?.winner, 'Ana');
  });

  test('guests are excluded by default but compete when the flag is on', () {
    final scores = [onHole1('Ana', 3), onHole1('Gus', 3)];

    // Default: Gus is a guest and invisible, so Ana is the lone birdie.
    final excluded = Skins.compute(scores, config(guests: {'Gus'}));
    expect(hole1(excluded)?.winner, 'Ana');

    // Flag on: Gus competes, both birdie, hole is cut.
    final included = Skins.compute(
      scores,
      config(guests: {'Gus'}, guestsInSideGames: true),
    );
    expect(hole1(included), isNull);
  });
}
