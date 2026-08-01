/// The four tee box colors a player can be assigned on the tee sheet, drawn as
/// a color bar on each player slot. Every bar carries a gold border regardless
/// of the color inside it.
///
/// Assignment follows the four-step engine below. Gold is an age override, not
/// a handicap bucket. The handicap breakpoints are club-configurable; the
/// values in [ClubTeeSettings] are the defaults every club starts with.
enum TeeBoxColor { black, blue, white, gold }

/// Per-club tee box settings. The Club Creator can change the handicap
/// breakpoints and the gold tee age threshold for their club. These defaults
/// apply until a club changes them.
class ClubTeeSettings {
  const ClubTeeSettings({
    this.blackMax = 4.4,
    this.blueMax = 9.4,
    this.goldAgeThreshold = 62,
  });

  /// Handicap at or below this is Black. Default 4.4.
  final double blackMax;

  /// Handicap above [blackMax] and at or below this is Blue. Default 9.4.
  /// Anything above this is White.
  final double blueMax;

  /// Age at or above this is assigned Gold tees before anything else is
  /// checked. Default 62.
  final int goldAgeThreshold;

  /// The middle range color for this club, used as the Guest default when no
  /// handicap is entered. Under default settings this is Blue.
  TeeBoxColor get middleRangeColor => TeeBoxColor.blue;
}

extension TeeBoxColorX on TeeBoxColor {
  String get label {
    switch (this) {
      case TeeBoxColor.black:
        return 'Black';
      case TeeBoxColor.blue:
        return 'Blue';
      case TeeBoxColor.white:
        return 'White';
      case TeeBoxColor.gold:
        return 'Gold';
    }
  }
}

/// The tee box assignment engine. Runs the four steps in strict order and
/// stops at the first one that resolves:
///
///   1. Age override: age at or above the club gold tee threshold assigns
///      Gold. This runs before the handicap is looked at.
///   2. No handicap yet: fewer than 3 scored rounds at this club returns null.
///      The player selects their own tee box on the tee sheet.
///   3. Manual override: the Club Creator has set an override for this player.
///      The override exists to correct the range result, so it resolves before
///      the ranges do.
///   4. Handicap ranges: apply the club range settings for Black, Blue, White.
///
/// Returns null when the player self-selects (step 2) or when no rule can
/// resolve (no age, no rounds, no handicap on file).
class TeeBoxEngine {
  TeeBoxEngine._();

  static TeeBoxColor? assign({
    int? age,
    double? handicap,
    int roundsPlayed = 0,
    TeeBoxColor? manualOverride,
    ClubTeeSettings settings = const ClubTeeSettings(),
  }) {
    // Step 1: age override.
    if (age != null && age >= settings.goldAgeThreshold) return TeeBoxColor.gold;

    // Step 2: no established handicap. Player self-selects.
    if (roundsPlayed < 3 || handicap == null) return manualOverride;

    // Step 3: manual override set by the Club Creator.
    if (manualOverride != null) return manualOverride;

    // Step 4: club-configured handicap ranges.
    if (handicap <= settings.blackMax) return TeeBoxColor.black;
    if (handicap <= settings.blueMax) return TeeBoxColor.blue;
    return TeeBoxColor.white;
  }

  /// Tee box for a Guest slot on the tee sheet. Guests are course backfill
  /// players with no profile, so the engine cannot resolve them normally.
  ///
  ///   No handicap entered      -> the club middle range color (Blue under
  ///                               default settings)
  ///   Official handicap entered -> the club range settings apply the same way
  ///                               as a member
  ///
  /// Guest handicap entries are used for that tee sheet only. They are never
  /// stored against a player record or fed into any handicap calculation.
  static TeeBoxColor guest({
    double? enteredHandicap,
    ClubTeeSettings settings = const ClubTeeSettings(),
  }) {
    if (enteredHandicap == null) return settings.middleRangeColor;
    if (enteredHandicap <= settings.blackMax) return TeeBoxColor.black;
    if (enteredHandicap <= settings.blueMax) return TeeBoxColor.blue;
    return TeeBoxColor.white;
  }
}
