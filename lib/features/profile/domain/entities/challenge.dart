import 'package:equatable/equatable.dart';

enum ChallengeStatus { won, lost, pending }

/// One head-to-head challenge in the golfer's history.
class Challenge extends Equatable {
  const Challenge({
    required this.id,
    required this.opponentName,
    required this.date,
    required this.status,
    this.resultSummary,
  });

  final String id;
  final String opponentName;
  final DateTime date;
  final ChallengeStatus status;
  final String? resultSummary;

  @override
  List<Object?> get props => [id, opponentName, date, status, resultSummary];
}
