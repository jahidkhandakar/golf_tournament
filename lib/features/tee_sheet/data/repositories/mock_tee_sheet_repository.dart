import '../../domain/entities/player_slot.dart';
import '../../domain/entities/roster_player.dart';
import '../../domain/entities/tee_group.dart';
import '../../domain/entities/tee_sheet.dart';
import '../../domain/repositories/tee_sheet_repository.dart';

/// In-memory stand-in for a real API-backed tee sheet builder. Seeded to match
/// the app's other mocks — the Riverbend Championship on the Championship Course
/// (see PlayController / MockClubRepository) — so the builder demonstrates every
/// slot state: a confirmed challenge pair (gold badge), a course guest, open
/// slots, and an unassigned roster.
///
/// Swap for an API implementation behind [TeeSheetRepository] when the backend
/// is ready; the widget layer never changes.
class MockTeeSheetRepository implements TeeSheetRepository {
  TeeSheet? _sheet;

  TeeSheet get _current => _sheet ??= _seed();

  Future<TeeSheet> _return(TeeSheet sheet) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return sheet;
  }

  @override
  Future<TeeSheet> getTeeSheet(String tournamentId) => _return(_current);

  @override
  Future<TeeSheet> assignPlayer({
    required String tournamentId,
    required String playerId,
    required int groupNumber,
    required SlotPosition position,
  }) async {
    final sheet = _current;
    final player = _findInRoster(sheet.roster, playerId);
    if (player == null) return _return(sheet); // not assignable

    RosterPlayer? displaced;
    final groups = sheet.groups.map((group) {
      if (group.groupNumber != groupNumber) return group;
      final slots = group.slots.map((slot) {
        if (slot.position != position) return slot;
        displaced = slot.player; // whoever was here (may be null / a guest)
        return PlayerSlot.withPlayer(position, player);
      }).toList();
      return group.copyWith(slots: slots);
    }).toList();

    final roster = [
      ...sheet.roster.where((p) => p.id != playerId),
      if (displaced != null) displaced!,
    ];

    _sheet = sheet.copyWith(groups: groups, roster: roster);
    return _return(_sheet!);
  }

  @override
  Future<TeeSheet> unassignSlot({
    required String tournamentId,
    required int groupNumber,
    required SlotPosition position,
  }) async {
    final sheet = _current;
    RosterPlayer? removed;
    final groups = sheet.groups.map((group) {
      if (group.groupNumber != groupNumber) return group;
      final slots = group.slots.map((slot) {
        if (slot.position != position) return slot;
        removed = slot.player; // guests are dropped, not returned
        return PlayerSlot.open(position);
      }).toList();
      return group.copyWith(slots: slots);
    }).toList();

    final roster = [
      ...sheet.roster,
      if (removed != null) removed!,
    ];

    _sheet = sheet.copyWith(groups: groups, roster: roster);
    return _return(_sheet!);
  }

  @override
  Future<TeeSheet> addGuest({
    required String tournamentId,
    required int groupNumber,
    required SlotPosition position,
    required String guestName,
  }) async {
    final sheet = _current;
    RosterPlayer? displaced;
    final groups = sheet.groups.map((group) {
      if (group.groupNumber != groupNumber) return group;
      final slots = group.slots.map((slot) {
        if (slot.position != position) return slot;
        displaced = slot.player;
        return PlayerSlot.guest(position, guestName);
      }).toList();
      return group.copyWith(slots: slots);
    }).toList();

    final roster = [
      ...sheet.roster,
      if (displaced != null) displaced!,
    ];

    _sheet = sheet.copyWith(groups: groups, roster: roster);
    return _return(_sheet!);
  }

  @override
  Future<TeeSheet> saveDraft(TeeSheet sheet) async {
    _sheet = sheet.copyWith(status: TeeSheetStatus.draft);
    return _return(_sheet!);
  }

  @override
  Future<TeeSheet> publish(String tournamentId) async {
    _sheet = _current.copyWith(status: TeeSheetStatus.published);
    return _return(_sheet!);
  }

  @override
  Future<void> emailToCourse(String tournamentId) async {
    // Real implementation hands off to the backend mail service; here we just
    // simulate the round-trip.
    await Future.delayed(const Duration(milliseconds: 250));
  }

  RosterPlayer? _findInRoster(List<RosterPlayer> roster, String id) {
    for (final p in roster) {
      if (p.id == id) return p;
    }
    return null;
  }

  // --- Seed data -----------------------------------------------------------

  static TeeSheet _seed() {
    // The logged-in user and their confirmed challenge opponent share pair id
    // 'cp1', so both slots render the gold Challenge badge.
    const jahid = RosterPlayer(
        id: 'u_jahid', name: 'Jahid Hasan', clubHandicap: 12.0, challengePairId: 'cp1');
    const marcus = RosterPlayer(
        id: 'm1', name: 'Marcus Thompson', clubHandicap: 8.2, challengePairId: 'cp1');
    const erin = RosterPlayer(id: 'm5', name: 'Erin Walsh', clubHandicap: 6.7);
    const priya = RosterPlayer(id: 'm3', name: 'Priya Kapoor', clubHandicap: 11.0);

    final group1 = TeeGroup(
      groupNumber: 1,
      teeTime: '7:10 AM',
      slots: const [
        PlayerSlot.withPlayer(SlotPosition.a, jahid),
        PlayerSlot.withPlayer(SlotPosition.b, marcus),
        PlayerSlot.open(SlotPosition.c),
        PlayerSlot.open(SlotPosition.d),
      ],
    );

    final group2 = TeeGroup(
      groupNumber: 2,
      teeTime: '7:20 AM',
      slots: const [
        PlayerSlot.withPlayer(SlotPosition.a, erin),
        PlayerSlot.withPlayer(SlotPosition.b, priya),
        PlayerSlot.guest(SlotPosition.c, 'Course Player (Guest)'),
        PlayerSlot.open(SlotPosition.d),
      ],
    );

    final group3 = TeeGroup(
      groupNumber: 3,
      teeTime: '7:30 AM',
      slots: const [
        PlayerSlot.open(SlotPosition.a),
        PlayerSlot.open(SlotPosition.b),
        PlayerSlot.open(SlotPosition.c),
        PlayerSlot.open(SlotPosition.d),
      ],
    );

    // Registered but not yet placed — the roster panel.
    const roster = <RosterPlayer>[
      RosterPlayer(id: 'm2', name: 'Dana Reyes', clubHandicap: 14.6),
      RosterPlayer(id: 'm4', name: 'Sam Ortiz', clubHandicap: 19.4),
      RosterPlayer(id: 'm8', name: 'Jordan Blake', clubHandicap: 8.1),
      RosterPlayer(id: 'm9', name: 'Casey Nguyen', clubHandicap: 9.4),
      RosterPlayer(id: 'm12', name: 'Riley Foster', clubHandicap: 10.2, isMainClub: false),
      RosterPlayer(id: 'm16', name: 'Taylor Brooks', clubHandicap: 22.3),
    ];

    return TeeSheet(
      tournamentId: 't_riverbend',
      tournamentName: 'Riverbend Championship',
      clubName: 'Riverbend Golf Club',
      courseName: 'Riverbend Championship Course',
      date: 'This weekend',
      firstTeeTime: '7:10 AM',
      intervalMinutes: 10,
      status: TeeSheetStatus.draft,
      groups: [group1, group2, group3],
      roster: roster,
      golfCourseEmail: 'proshop@riverbendgolf.example',
    );
  }
}
