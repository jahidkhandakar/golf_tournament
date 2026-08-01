import '../entities/challenge_approval.dart';

/// In-tournament challenges (§3, §6). Every sent challenge is recorded here.
/// Same-club challenges ([needsApproval] true) start pending and count only once
/// a Club Creator / sub-admin approves them; others are confirmed immediately.
/// Confirmed challenges are resolved when the round's scorecard is submitted.
abstract class ChallengeApprovalRepository {
  Future<ChallengeApproval> submit({
    required String tournamentId,
    required String clubName,
    required String challengerName,
    required String opponentName,
    required bool needsApproval,
  });

  Future<List<ChallengeApproval>> pending(String tournamentId);

  Future<int> pendingCount(String tournamentId);

  /// Confirmed (approved) challenges awaiting the round result — resolved at
  /// scorecard submission.
  Future<List<ChallengeApproval>> confirmedFor(String tournamentId);

  /// Live challenges directed at [opponentName] (pending or confirmed) — the
  /// ones they can still decline.
  Future<List<ChallengeApproval>> incomingFor(String opponentName);

  Future<void> approve(String id);

  Future<void> reject(String id);

  /// The challenged player declines — they take the decline penalty (§3).
  Future<void> decline(String id);

  /// Marks a challenge resolved after its ladder result has been applied.
  Future<void> markResolved(String id);
}
