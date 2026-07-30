import '../entities/play_request.dart';

/// Tournament registration (§1): members register directly; non-members submit
/// a Request to Play that a Club Creator / sub-admin approves or rejects.
abstract class RegistrationRepository {
  Future<int> registeredCount(String tournamentId);

  /// Names of players registered for this tournament — the source for the tee
  /// sheet's roster panel.
  Future<List<String>> registeredPlayers(String tournamentId);

  Future<bool> isRegistered(String tournamentId, String playerName);

  /// Direct registration for a club member.
  Future<void> registerMember(String tournamentId, String playerName);

  /// The player's own request for this tournament, if any (to show its status).
  Future<PlayRequest?> myRequest(String tournamentId, String playerName);

  /// Non-member Request to Play — creates a pending request.
  Future<PlayRequest> requestToPlay(String tournamentId, String playerName, String homeClub);

  /// Pending requests for the admin queue.
  Future<List<PlayRequest>> pendingRequests(String tournamentId);

  /// Approve a request → the player becomes registered.
  Future<void> approve(String requestId);

  Future<void> reject(String requestId);
}
