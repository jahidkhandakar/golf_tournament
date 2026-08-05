import 'entities/contest_config.dart';

/// KP Live: on-course closest to the pin measuring with photo proof.
///
/// Flow: first group pins a KP hole (GPS marker for the 40-yard geofence in
/// the wired build). A teammate (never the player whose ball it is) runs the
/// two-anchor capture: dot inside the cup with flag removed (picture 1), ruler
/// activates, walk to the ball, ball inside the target circle (picture 2),
/// distance recorded. Photos come from the live AR session only, never the
/// gallery.
///
/// Board: a submission must strictly beat the current leader in the player's
/// category. Matching is not enough — first recorded stands. A new leader's
/// photos replace the old leader's (deleted), but every dethroned distance
/// stays on the board in order. Ball must be on the green (rule note on the
/// capture screen). Staff can remove disputed entries. Staff placard entry
/// overrides KP Live at Final Results.
class KpEntry {
  const KpEntry({
    required this.hole,
    required this.player,
    required this.measuredBy,
    required this.category,
    required this.distanceFeet,
    required this.recordedAt,
    this.photosRetained = true,
  });

  final int hole;
  final String player;
  final String measuredBy;
  final ContestCategory category;
  final double distanceFeet;
  final DateTime recordedAt;
  final bool photosRetained;

  KpEntry copyWith({bool? photosRetained}) => KpEntry(
        hole: hole,
        player: player,
        measuredBy: measuredBy,
        category: category,
        distanceFeet: distanceFeet,
        recordedAt: recordedAt,
        photosRetained: photosRetained ?? this.photosRetained,
      );
}

enum KpSubmitResult { accepted, notCloser, measurerIsPlayer, holeNotKp, resultsFinal }
