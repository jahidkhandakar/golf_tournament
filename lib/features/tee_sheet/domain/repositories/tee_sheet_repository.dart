import '../entities/player_slot.dart';
import '../entities/tee_sheet.dart';

/// Tee sheet builder operations, all keyed by tournament (§5.4). Every mutation
/// returns the updated [TeeSheet] so the caller (a controller/notifier) can
/// re-render from a single source of truth.
///
/// These are Club Creator / sub-admin actions only — gate the UI with
/// PermissionService before calling any of them.
abstract class TeeSheetRepository {
  /// Load the tournament's sheet, creating an empty draft if none exists yet.
  Future<TeeSheet> getTeeSheet(String tournamentId);

  /// Drag a roster player into a group slot. The player leaves the roster; if
  /// the slot already held an app player, that player is returned to the roster.
  Future<TeeSheet> assignPlayer({
    required String tournamentId,
    required String playerId,
    required int groupNumber,
    required SlotPosition position,
  });

  /// Clear a slot back to OPEN. An app player goes back to the roster; a guest
  /// is simply removed.
  Future<TeeSheet> unassignSlot({
    required String tournamentId,
    required int groupNumber,
    required SlotPosition position,
  });

  /// Course backfill: mark a slot as a named Guest with no profile link (§5.3).
  Future<TeeSheet> addGuest({
    required String tournamentId,
    required int groupNumber,
    required SlotPosition position,
    required String guestName,
  });

  /// Persist the sheet without publishing — Save Draft (§5.4).
  Future<TeeSheet> saveDraft(TeeSheet sheet);

  /// Publish the sheet to all registered players (§5.4).
  Future<TeeSheet> publish(String tournamentId);

  /// Email the current sheet as HTML to the tournament's golf_course_email, with
  /// open slots marked OPEN for backfill (§5.5). No-op stub until the backend
  /// mail service exists.
  Future<void> emailToCourse(String tournamentId);
}
