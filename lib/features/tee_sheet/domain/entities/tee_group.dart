import 'package:equatable/equatable.dart';

import 'player_slot.dart';

/// One tee time = one group of exactly 4 player slots (§5.1). The group number
/// combined with a slot's position letter is the Group ID, e.g. `1-A`…`1-D`.
class TeeGroup extends Equatable {
  const TeeGroup({
    required this.groupNumber,
    required this.teeTime,
    required this.slots,
    this.startingHole,
  });

  final int groupNumber;

  /// Display tee time for this group, e.g. `7:10 AM`. Regular Start groups are
  /// spaced by the sheet's interval; a Shotgun Start shares one start time.
  final String teeTime;

  /// For a Shotgun Start, the hole this group tees off from (all groups share
  /// [teeTime]). Null for a Regular Start, where [teeTime] differs per group.
  final int? startingHole;

  /// Always length 4, positions A–D in order.
  final List<PlayerSlot> slots;

  /// The Group ID for a given slot, e.g. `1-A`.
  String slotId(SlotPosition position) => '$groupNumber-${position.letter}';

  bool get isFull => slots.every((s) => !s.isOpen);
  int get openCount => slots.where((s) => s.isOpen).length;

  TeeGroup copyWith({String? teeTime, List<PlayerSlot>? slots}) => TeeGroup(
        groupNumber: groupNumber,
        teeTime: teeTime ?? this.teeTime,
        slots: slots ?? this.slots,
        startingHole: startingHole,
      );

  @override
  List<Object?> get props => [groupNumber, teeTime, startingHole, slots];
}
