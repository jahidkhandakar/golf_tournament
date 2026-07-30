import 'package:equatable/equatable.dart';

import 'roster_player.dart';

/// Position letter within a group. Each group holds exactly 4 slots (A–D), so
/// the group number + this letter form the Group ID from the spec, e.g. `1-A`.
enum SlotPosition { a, b, c, d }

extension SlotPositionX on SlotPosition {
  String get letter {
    switch (this) {
      case SlotPosition.a:
        return 'A';
      case SlotPosition.b:
        return 'B';
      case SlotPosition.c:
        return 'C';
      case SlotPosition.d:
        return 'D';
    }
  }
}

/// One of the four slots in a group. A slot is always in exactly one state:
///   - open   : nobody assigned yet (shows as OPEN, and as OPEN in the course email)
///   - player : an app user is assigned ([player] set)
///   - guest  : the golf course backfilled it ([guestName] set, no profile link)
class PlayerSlot extends Equatable {
  /// An empty, unfilled slot.
  const PlayerSlot.open(this.position)
      : player = null,
        guestName = null;

  /// A slot filled by an app user dragged from the roster.
  const PlayerSlot.withPlayer(this.position, RosterPlayer this.player)
      : guestName = null;

  /// A slot backfilled by the golf course with a non-app-user guest (§5.3).
  const PlayerSlot.guest(this.position, String this.guestName) : player = null;

  final SlotPosition position;
  final RosterPlayer? player;
  final String? guestName;

  bool get isOpen => player == null && guestName == null;
  bool get isGuest => guestName != null;

  /// True when this slot's player is half of a confirmed challenge pair — drives
  /// the gold Challenge badge (§5.3). Guests and open slots never show it.
  bool get hasChallengeBadge => player?.challengePairId != null;

  /// What the tee sheet row renders as the occupant's name.
  String get displayName {
    if (isGuest) return guestName!;
    if (player != null) return player!.name;
    return 'OPEN';
  }

  @override
  List<Object?> get props => [position, player, guestName];
}
