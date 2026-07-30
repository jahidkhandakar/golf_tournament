import '../entities/invite.dart';

/// Tournament invitations (§1). A Club Creator / sub-admin invites players; the
/// invited player accepts (registering them directly) or declines.
abstract class InviteRepository {
  Future<Invite> invite({
    required String tournamentId,
    required String clubName,
    required String playerName,
  });

  /// The invite addressed to [playerName] for this tournament, if any.
  Future<Invite?> inviteFor(String tournamentId, String playerName);

  /// Invites the admin has sent for this tournament.
  Future<List<Invite>> sentInvites(String tournamentId);

  Future<void> accept(String id);

  Future<void> decline(String id);
}
