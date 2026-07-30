import 'package:equatable/equatable.dart';

import 'player_score.dart';

/// A tournament's scorecard — one [PlayerScore] per registered player, entered
/// by a Club Creator / sub-admin after the round (§6). Players do not self-enter.
class Scorecard extends Equatable {
  const Scorecard({required this.tournamentId, required this.scores, this.submitted = false});

  final String tournamentId;
  final List<PlayerScore> scores;
  final bool submitted;

  bool get allScored => scores.isNotEmpty && scores.every((s) => s.hasScore);

  @override
  List<Object?> get props => [tournamentId, scores, submitted];
}
