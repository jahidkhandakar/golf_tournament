import 'package:equatable/equatable.dart';

enum ChallengeApprovalStatus { pending, approved, rejected }

/// A same-club, in-tournament challenge awaiting a Club Creator / sub-admin
/// decision (§3). Approval is what makes the challenge count toward the Club
/// Leaderboard and Top 50 — it keeps those rankings legitimate.
class ChallengeApproval extends Equatable {
  const ChallengeApproval({
    required this.id,
    required this.tournamentId,
    required this.clubName,
    required this.challengerName,
    required this.opponentName,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String tournamentId;
  final String clubName;
  final String challengerName;
  final String opponentName;
  final ChallengeApprovalStatus status;
  final DateTime createdAt;

  ChallengeApproval copyWith({ChallengeApprovalStatus? status}) => ChallengeApproval(
        id: id,
        tournamentId: tournamentId,
        clubName: clubName,
        challengerName: challengerName,
        opponentName: opponentName,
        status: status ?? this.status,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props =>
      [id, tournamentId, clubName, challengerName, opponentName, status, createdAt];
}
