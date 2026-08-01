import '../../domain/entities/challenge_approval.dart';
import '../../domain/repositories/challenge_approval_repository.dart';

/// In-memory challenge-approval store. Seeded with a pending same-club challenge
/// on the Riverbend tournament so the Club Creator (Jahid) has one to approve or
/// reject out of the box.
class MockChallengeApprovalRepository implements ChallengeApprovalRepository {
  final List<ChallengeApproval> _approvals = [
    ChallengeApproval(
      id: 'ca1',
      tournamentId: 't_riverbend',
      clubName: 'Riverbend Golf Club',
      challengerName: 'Priya Kapoor',
      opponentName: 'Marcus Thompson',
      status: ChallengeApprovalStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    // A confirmed challenge aimed at the logged-in user — they can decline it
    // (and take the decline penalty).
    ChallengeApproval(
      id: 'ca2',
      tournamentId: 't_riverbend',
      clubName: 'Riverbend Golf Club',
      challengerName: 'Erin Walsh',
      opponentName: 'Jahid',
      status: ChallengeApprovalStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  Future<T> _delayed<T>(T value) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return value;
  }

  @override
  Future<ChallengeApproval> submit({
    required String tournamentId,
    required String clubName,
    required String challengerName,
    required String opponentName,
    required bool needsApproval,
  }) {
    final approval = ChallengeApproval(
      id: 'ca${DateTime.now().millisecondsSinceEpoch}',
      tournamentId: tournamentId,
      clubName: clubName,
      challengerName: challengerName,
      opponentName: opponentName,
      // Same-club 8+ waits for approval; everything else is confirmed on send.
      status: needsApproval ? ChallengeApprovalStatus.pending : ChallengeApprovalStatus.approved,
      createdAt: DateTime.now(),
    );
    _approvals.add(approval);
    return _delayed(approval);
  }

  @override
  Future<List<ChallengeApproval>> pending(String tournamentId) => _delayed(
        _approvals
            .where((a) => a.tournamentId == tournamentId && a.status == ChallengeApprovalStatus.pending)
            .toList(),
      );

  @override
  Future<int> pendingCount(String tournamentId) async => (await pending(tournamentId)).length;

  @override
  Future<List<ChallengeApproval>> confirmedFor(String tournamentId) => _delayed(
        _approvals
            .where((a) => a.tournamentId == tournamentId && a.status == ChallengeApprovalStatus.approved)
            .toList(),
      );

  @override
  Future<List<ChallengeApproval>> incomingFor(String opponentName) => _delayed(
        _approvals
            .where((a) =>
                a.opponentName == opponentName &&
                (a.status == ChallengeApprovalStatus.pending ||
                    a.status == ChallengeApprovalStatus.approved))
            .toList(),
      );

  @override
  Future<void> approve(String id) => _setStatus(id, ChallengeApprovalStatus.approved);

  @override
  Future<void> reject(String id) => _setStatus(id, ChallengeApprovalStatus.rejected);

  @override
  Future<void> decline(String id) => _setStatus(id, ChallengeApprovalStatus.declined);

  @override
  Future<void> markResolved(String id) => _setStatus(id, ChallengeApprovalStatus.resolved);

  Future<void> _setStatus(String id, ChallengeApprovalStatus status) {
    final index = _approvals.indexWhere((a) => a.id == id);
    if (index >= 0) _approvals[index] = _approvals[index].copyWith(status: status);
    return _delayed(null);
  }
}
