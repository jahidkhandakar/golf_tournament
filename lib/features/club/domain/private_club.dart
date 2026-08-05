import 'package:flutter/foundation.dart';

/// Private club member slots and access codes.
///
/// The creator is the sole gatekeeper. They create a slot (display name of
/// their choosing), pay the per-member fee at that moment, and receive a
/// unique one-time access code to hand to the person however they want. The
/// member redeems the code, creates their own login, and can change their
/// display name once inside. The code binds once and dies.
///
/// Privacy: the app never collects the member's identity through the invite.
/// Only the creator knows who their members really are, because they handed
/// the codes out personally. Payment exists only on the creator's side, so
/// members leave no payment trail linking them to the club.
class MemberSlot {
  MemberSlot({
    required this.code,
    required this.displayName,
    this.redeemed = false,
    this.paidAt,
  });

  /// Unique one-time access code, generated when the creator pays for the
  /// slot. Format: three groups, e.g. GGW-7K2M-XQ4R.
  final String code;

  /// Display name the creator set for the slot. The member can change it
  /// after redeeming; their friends already know who they are.
  String displayName;

  /// True once an account has bound to this code. A redeemed code is dead.
  bool redeemed;

  /// When the creator paid the per-member fee for this slot. Billing runs
  /// through Stripe on the creator's account only.
  final DateTime? paidAt;
}

/// Session state for private club slot management. Backend owns this once
/// wired: slots table, Stripe per-member charge on slot creation, one-shot
/// redemption endpoint.
class PrivateClubState extends ChangeNotifier {
  final Map<String, List<MemberSlot>> _slotsByClub = {};

  List<MemberSlot> slotsFor(String clubId) =>
      List.unmodifiable(_slotsByClub[clubId] ?? const []);

  /// Creator pays, slot is created, code comes back. Mock generates the code
  /// locally; the wired build charges Stripe first and the server issues it.
  MemberSlot addSlot(String clubId, String displayName) {
    final code = _generateCode();
    final slot = MemberSlot(code: code, displayName: displayName, paidAt: DateTime.now());
    _slotsByClub.putIfAbsent(clubId, () => []).add(slot);
    notifyListeners();
    return slot;
  }

  /// One-shot redemption. Returns the slot on success, null if the code is
  /// unknown or already used.
  MemberSlot? redeem(String code) {
    for (final slots in _slotsByClub.values) {
      for (final s in slots) {
        if (s.code == code && !s.redeemed) {
          s.redeemed = true;
          notifyListeners();
          return s;
        }
      }
    }
    return null;
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final seed = DateTime.now().microsecondsSinceEpoch;
    String part(int offset) => List.generate(
        4, (i) => chars[(seed >> (i * 5 + offset)) % chars.length]).join();
    return 'GGW-${part(0)}-${part(3)}';
  }
}
