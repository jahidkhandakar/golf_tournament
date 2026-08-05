import 'package:flutter/foundation.dart';

import 'entities/contest_config.dart';
import 'entities/player_score.dart';
import 'kp_live.dart';
import 'skins.dart';

/// Whether results are still being entered or locked as final.
enum ResultsStatus { inProgress, finalized }

/// Live tournament results state. The entry screen writes hole scores and
/// placard winners here; the results view listens and updates immediately, so
/// players watch the board move while cards are still being entered.
///
/// Everything stays marked In Progress, and skin values keep shifting as later
/// groups go in, until an authorized user presses Final Results. Only at that
/// point do the handicap engine, Top 50, Club Leaderboard, and challenge
/// outcomes fire; live entry never feeds them, so partial cards cannot corrupt
/// a handicap or flip a challenge early.
class LiveResults extends ChangeNotifier {
  LiveResults({
    required this.tournamentId,
    required this.config,
    required List<String> players,
    Map<String, double> handicaps = const {},
  })  : _handicaps = Map.of(handicaps),
        _deductMid = config.skinsDeductMidPercent,
        _deductPlus = config.skinsDeductPlusPercent,
        _scores = {
          for (final p in players) p: List<int>.filled(18, 0),
        };

  final String tournamentId;
  final ContestConfig config;

  /// Club handicap per player, read by the skins deduction bands.
  final Map<String, double> _handicaps;

  int _deductMid;
  int _deductPlus;

  final Set<int> _kpPins = {};
  final List<KpEntry> _kpEntries = [];

  /// The live deduction settings. The creator can adjust these any time until
  /// results go final; the board recomputes immediately.
  int get deductMidPercent => _deductMid;
  int get deductPlusPercent => _deductPlus;

  void setDeductions({required int midPercent, required int plusPercent}) {
    if (isFinal) return;
    _deductMid = midPercent;
    _deductPlus = plusPercent;
    notifyListeners();
  }

  final Map<String, List<int>> _scores;
  final List<ContestWinner> _contestWinners = [];
  ResultsStatus _status = ResultsStatus.inProgress;

  ResultsStatus get status => _status;
  bool get isFinal => _status == ResultsStatus.finalized;
  bool _finalResultsPushSent = false;
  bool get finalResultsPushSent => _finalResultsPushSent;

  List<String> get players => _scores.keys.toList();

  List<int> holesForPlayer(String player) => List.unmodifiable(_scores[player] ?? List.filled(18, 0));

  int scoreFor(String player, int hole) => _scores[player]?[hole - 1] ?? 0;

  void enterScore(String player, int hole, int strokes) {
    if (isFinal) return;
    final row = _scores[player];
    if (row == null || hole < 1 || hole > 18) return;
    row[hole - 1] = strokes;
    notifyListeners();
  }

  void clearScore(String player, int hole) => enterScore(player, hole, 0);

  int frontNine(String player) =>
      _scores[player]?.take(9).where((v) => v > 0).fold(0, (a, b) => a! + b) ?? 0;

  int backNine(String player) =>
      _scores[player]?.skip(9).where((v) => v > 0).fold(0, (a, b) => a! + b) ?? 0;

  int total(String player) => frontNine(player) + backNine(player);

  int holesEntered(String player) =>
      _scores[player]?.where((v) => v > 0).length ?? 0;

  bool get allCardsComplete =>
      _scores.values.every((row) => row.every((v) => v > 0));

  List<String> get playersWithMissingHoles => _scores.entries
      .where((e) => e.value.any((v) => v == 0))
      .map((e) => e.key)
      .toList();

  /// Snapshot as PlayerScore list for the skins engine and legacy views.
  List<PlayerScore> get asPlayerScores => _scores.entries
      .map((e) => PlayerScore(
            playerName: e.key,
            gross: e.value.every((v) => v > 0) ? e.value.fold<int>(0, (a, b) => a + b) : null,
            holes: e.value.any((v) => v > 0) ? List<int>.from(e.value) : null,
          ))
      .toList();

  Set<int> get kpPinnedHoles => Set.unmodifiable(_kpPins);

  void pinKpHole(int hole) {
    if (isFinal || !config.kpHoles.contains(hole)) return;
    if (_kpPins.add(hole)) notifyListeners();
  }

  List<KpEntry> kpBoard(int hole, ContestCategory category) {
    final list = _kpEntries
        .where((e) => e.hole == hole && e.category == category)
        .toList()
      ..sort((a, b) => a.distanceFeet.compareTo(b.distanceFeet));
    return list;
  }

  KpSubmitResult submitKp({
    required int hole,
    required String player,
    required String measuredBy,
    required ContestCategory category,
    required double distanceFeet,
  }) {
    if (isFinal) return KpSubmitResult.resultsFinal;
    if (!config.kpHoles.contains(hole)) return KpSubmitResult.holeNotKp;
    if (player == measuredBy) return KpSubmitResult.measurerIsPlayer;
    final board = kpBoard(hole, category);
    if (board.isNotEmpty && distanceFeet >= board.first.distanceFeet) {
      return KpSubmitResult.notCloser;
    }
    for (var i = 0; i < _kpEntries.length; i++) {
      final e = _kpEntries[i];
      if (e.hole == hole && e.category == category && e.photosRetained) {
        _kpEntries[i] = e.copyWith(photosRetained: false);
      }
    }
    _kpEntries.add(KpEntry(
      hole: hole,
      player: player,
      measuredBy: measuredBy,
      category: category,
      distanceFeet: distanceFeet,
      recordedAt: DateTime.now(),
    ));
    notifyListeners();
    return KpSubmitResult.accepted;
  }

  void removeKpEntry(KpEntry entry) {
    if (isFinal) return;
    _kpEntries.remove(entry);
    notifyListeners();
  }

  List<({int hole, ContestCategory category, String player, double distanceFeet})>
      get kpLiveLeaders {
    final out = <({int hole, ContestCategory category, String player, double distanceFeet})>[];
    for (final hole in config.kpHoles) {
      for (final cat in config.useCategories
          ? const [ContestCategory.men, ContestCategory.seniorMen, ContestCategory.women, ContestCategory.seniorWomen]
          : const [ContestCategory.open]) {
        final board = kpBoard(hole, cat);
        if (board.isNotEmpty) {
          out.add((hole: hole, category: cat, player: board.first.player, distanceFeet: board.first.distanceFeet));
        }
      }
    }
    return out;
  }

  /// Live tournament-wide skins under the configured rule, payout mode, and
  /// current deduction settings.
  List<SkinResult> get skins => Skins.compute(
        asPlayerScores,
        config,
        handicaps: _handicaps,
        deductMidPercent: _deductMid,
        deductPlusPercent: _deductPlus,
      );

  /// Live leaderboard: players ordered by strokes over the holes they have
  /// entered so far (thru N), complete cards first at the end of entry.
  List<({String player, int thru, int strokes})> get liveBoard {
    final rows = [
      for (final p in players) (player: p, thru: holesEntered(p), strokes: total(p)),
    ]..sort((a, b) {
        if (a.thru == 0 && b.thru == 0) return 0;
        if (a.thru == 0) return 1;
        if (b.thru == 0) return -1;
        final ra = a.strokes / a.thru;
        final rb = b.strokes / b.thru;
        return ra.compareTo(rb);
      });
    return rows;
  }

  // ── KP and long drive placards ─────────────────────────────────────────

  List<ContestWinner> get contestWinners => List.unmodifiable(_contestWinners);

  void recordContestWinner(ContestWinner winner) {
    if (isFinal) return;
    _contestWinners.removeWhere((w) =>
        w.hole == winner.hole &&
        w.category == winner.category &&
        w.isLongDrive == winner.isLongDrive);
    if (winner.playerName.isNotEmpty) _contestWinners.add(winner);
    notifyListeners();
  }

  /// hole -> value for KP payouts under the payout mode. A KP hole counts as
  /// won when at least one category slot on it has a name.
  Map<int, double> get kpValues => Skins.contestValues(
        eligibleHoles: config.kpHoles,
        wonHoles: _contestWinners
            .where((w) => !w.isLongDrive)
            .map((w) => w.hole)
            .toSet(),
        pot: config.kpPot,
        mode: config.payoutMode,
      );

  Map<int, double> get longDriveValues => Skins.contestValues(
        eligibleHoles: config.longDriveHoles,
        wonHoles: _contestWinners
            .where((w) => w.isLongDrive)
            .map((w) => w.hole)
            .toSet(),
        pot: config.longDrivePot,
        mode: config.payoutMode,
      );

  /// Locks entry and marks results final. The caller runs the engine hooks
  /// (handicap, ladders, challenge outcomes) after this returns true.
  bool finalize() {
    if (isFinal) return false;
    _status = ResultsStatus.finalized;
    _finalResultsPushSent = true;
    // Backend: send push notification to all tournament players.
    notifyListeners();
    return true;
  }
}

/// Session registry so the entry screen and the results view share one
/// LiveResults per tournament. Server side once the backend is wired.
class LiveResultsRegistry {
  final Map<String, LiveResults> _byTournament = {};

  LiveResults of(String tournamentId,
      {required ContestConfig config,
      required List<String> players,
      Map<String, double> handicaps = const {}}) {
    return _byTournament.putIfAbsent(
      tournamentId,
      () => LiveResults(
          tournamentId: tournamentId,
          config: config,
          players: players,
          handicaps: handicaps),
    );
  }

  LiveResults? existing(String tournamentId) => _byTournament[tournamentId];
}
