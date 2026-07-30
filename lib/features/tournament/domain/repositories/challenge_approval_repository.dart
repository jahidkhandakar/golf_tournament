import '../entities/challenge_approval.dart';

/// In-tournament challenge approvals (§3). Same-club challenges are submitted
/// here as pending and only count once a Club Creator / sub-admin approves them.
abstract class ChallengeApprovalRepository {
  Future<ChallengeApproval> submit({
    required String tournamentId,
    required String clubName,
    required String challengerName,
    required String opponentName,
  });

  Future<List<ChallengeApproval>> pending(String tournamentId);

  Future<int> pendingCount(String tournamentId);

  Future<void> approve(String id);

  Future<void> reject(String id);
}
