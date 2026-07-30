import '../../domain/entities/invite.dart';
import '../../domain/repositories/invite_repository.dart';

/// In-memory invite store. Seeded so both sides are demoable: the logged-in user
/// (Jahid) has a pending invite to the Pine Valley tournament — a club he's not
/// in — so he can accept without requesting; and the Riverbend admin has a
/// pending sent invite in their outbox.
class MockInviteRepository implements InviteRepository {
  final List<Invite> _invites = [
    Invite(
      id: 'i1',
      tournamentId: 't_pinevalley',
      clubName: 'Pine Valley Muni',
      playerName: 'Jahid',
      status: InviteStatus.pending,
      invitedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Invite(
      id: 'i2',
      tournamentId: 't_riverbend',
      clubName: 'Riverbend Golf Club',
      playerName: 'Alex Rivera',
      status: InviteStatus.pending,
      invitedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  Future<T> _delayed<T>(T value) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return value;
  }

  @override
  Future<Invite> invite({
    required String tournamentId,
    required String clubName,
    required String playerName,
  }) {
    final invite = Invite(
      id: 'i${DateTime.now().millisecondsSinceEpoch}',
      tournamentId: tournamentId,
      clubName: clubName,
      playerName: playerName,
      status: InviteStatus.pending,
      invitedAt: DateTime.now(),
    );
    _invites.add(invite);
    return _delayed(invite);
  }

  @override
  Future<Invite?> inviteFor(String tournamentId, String playerName) {
    Invite? found;
    for (final i in _invites) {
      if (i.tournamentId == tournamentId && i.playerName == playerName) found = i;
    }
    return _delayed(found);
  }

  @override
  Future<List<Invite>> sentInvites(String tournamentId) =>
      _delayed(_invites.where((i) => i.tournamentId == tournamentId).toList());

  @override
  Future<void> accept(String id) => _setStatus(id, InviteStatus.accepted);

  @override
  Future<void> decline(String id) => _setStatus(id, InviteStatus.declined);

  Future<void> _setStatus(String id, InviteStatus status) {
    final index = _invites.indexWhere((i) => i.id == id);
    if (index >= 0) _invites[index] = _invites[index].copyWith(status: status);
    return _delayed(null);
  }
}
