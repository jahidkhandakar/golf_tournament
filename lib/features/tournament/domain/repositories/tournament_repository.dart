import '../entities/tournament.dart';

abstract class TournamentRepository {
  /// Creates a tournament and returns the stored record. Caller must be a Club
  /// Creator / sub-admin of [Tournament.clubName] (gate via PermissionService).
  Future<Tournament> createTournament(Tournament tournament);

  /// Tournaments the current user runs, newest first — for the manage/list view.
  Future<List<Tournament>> getMyTournaments();

  /// A single tournament by id (null if it doesn't exist).
  Future<Tournament?> getTournament(String id);
}
