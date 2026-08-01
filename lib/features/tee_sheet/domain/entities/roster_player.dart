import 'package:equatable/equatable.dart';

import 'tee_box_color.dart';

/// A registered player available to be placed on the tee sheet. Lives in the
/// roster panel until a Club Creator or sub-admin drags them into a group
/// slot.
///
/// [isMainClub] drives the Main Club indicator. [challengePairId] and
/// [preferredPartnerId] let the builder pre-group players automatically: two
/// players sharing a [challengePairId] are a confirmed challenge pair (gold
/// badge); [preferredPartnerId] is a submitted 4some pairing preference.
class RosterPlayer extends Equatable {
  const RosterPlayer({
    required this.id,
    required this.name,
    required this.clubHandicap,
    this.age,
    this.roundsPlayed = 3,
    this.teeBoxOverride,
    this.isMainClub = true,
    this.challengePairId,
    this.preferredPartnerId,
  });

  final String id;
  final String name;

  /// Handicap within the club running this tournament. Tee box color and any
  /// club-scoped ranking use this, not the player's global handicap.
  final double clubHandicap;

  /// Age drives the Gold tee override: at or above the club gold tee age
  /// threshold the player is assigned Gold before handicap is looked at.
  final int? age;

  /// Scored rounds at this club. Under 3 rounds there is no established
  /// handicap and the player self-selects their tee box.
  final int roundsPlayed;

  /// A manual tee box override set by the Club Creator for this player.
  final TeeBoxColor? teeBoxOverride;

  final bool isMainClub;
  final String? challengePairId;
  final String? preferredPartnerId;

  /// Tee box color for this player, resolved by the four-step engine: age
  /// override, then no-handicap self-select, then manual override, then the
  /// club handicap ranges. Null means the player self-selects at the course.
  TeeBoxColor? get teeBoxColor => TeeBoxEngine.assign(
        age: age,
        handicap: clubHandicap,
        roundsPlayed: roundsPlayed,
        manualOverride: teeBoxOverride,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        clubHandicap,
        age,
        roundsPlayed,
        teeBoxOverride,
        isMainClub,
        challengePairId,
        preferredPartnerId,
      ];
}
