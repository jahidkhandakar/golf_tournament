/// Single source of truth for user-facing product **labels** (display text).
///
/// INTEGRITY RULE — read before touching:
/// The internal vocabulary stays `tournament` / `outing` **everywhere** in code
/// and data: class names, folders, routes, enums, JSON keys, and the backend
/// (API paths, Mongo collections). Those never change. Only the human-visible
/// TEXT changes. Route every on-screen string for these concepts through this
/// class so a future relabel — or localization — is a one-file change and no
/// stray literal drifts out of sync with the rest.
///
/// Mapping (Stan, Aug 2026):
///   internal `tournament` -> displayed as "Events"
///   internal `outing`     -> displayed as "Pickup"
///   "Looking to Play"     -> unchanged
///
/// Do NOT use these values as identifiers, map keys, enum names, or API fields.
class AppLabels {
  const AppLabels._();

  // ── Home category tabs ────────────────────────────────────────────────
  /// Plural label for the club-run rounds tab. Internal type: `tournament`.
  static const String events = 'Events';

  /// Plural label for the casual player-organized rounds tab. Internal: `outing`.
  static const String pickup = 'Pickup';

  /// Full label for the "looking to play" tab (unchanged per Stan).
  static const String lookingToPlay = 'Looking to Play';

  /// Abbreviated tab caption where space is tight.
  static const String looking = 'Looking';

  // ── Singular forms (for titles / buttons) ─────────────────────────────
  /// Singular of [events]. Internal type: `tournament`.
  static const String event = 'Event';

  /// Singular of [pickup]. Internal type: `outing`.
  static const String pickupRound = 'Pickup Round';
}
