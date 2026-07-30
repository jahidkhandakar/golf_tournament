import 'package:equatable/equatable.dart';

import 'tee_box_color.dart';

/// A registered player available to be placed on the tee sheet. Lives in the
/// roster panel (§5.2) until a Club Creator / sub-admin drags them into a group
/// slot.
///
/// [isMainClub] drives the "Main Club" indicator. [challengePairId] and
/// [preferredPartnerId] let the builder pre-group players automatically (§5.4):
/// two players sharing a [challengePairId] are a confirmed challenge pair (gold
/// badge); [preferredPartnerId] is a submitted 4some pairing preference.
class RosterPlayer extends Equatable {
  const RosterPlayer({
    required this.id,
    required this.name,
    required this.clubHandicap,
    this.isMainClub = true,
    this.challengePairId,
    this.preferredPartnerId,
  });

  final String id;
  final String name;

  /// Handicap within the club running this tournament — tee box color and any
  /// club-scoped ranking use this, not the player's global handicap.
  final double clubHandicap;
  final bool isMainClub;
  final String? challengePairId;
  final String? preferredPartnerId;

  /// Tee box color for this player, derived from [clubHandicap]. See
  /// [TeeBoxColorX.fromHandicap] — mapping is provisional pending the client.
  TeeBoxColor get teeBoxColor => TeeBoxColorX.fromHandicap(clubHandicap);

  @override
  List<Object?> get props =>
      [id, name, clubHandicap, isMainClub, challengePairId, preferredPartnerId];
}
