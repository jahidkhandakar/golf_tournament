/// The four tee box colors a player can be assigned on the tee sheet, drawn as
/// a color bar on each player slot. Per the GGW Connect build spec (§5.3) the
/// color is derived from the player's handicap.
///
/// IMPORTANT: the exact handicap ranges for each color are still pending from
/// the client — see follow-up question #4 to Stan. [TeeBoxColorX.fromHandicap]
/// below uses a PROVISIONAL mapping so the builder is renderable today; when the
/// real thresholds arrive, this is the only place that changes.
enum TeeBoxColor { black, blue, white, gold }

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

  /// PROVISIONAL handicap → tee box mapping (lower handicap = harder tee).
  /// TODO(stan): replace these cutoffs with the confirmed ranges.
  static TeeBoxColor fromHandicap(double handicap) {
    if (handicap <= 5) return TeeBoxColor.black;
    if (handicap <= 12) return TeeBoxColor.blue;
    if (handicap <= 20) return TeeBoxColor.white;
    return TeeBoxColor.gold;
  }
}
