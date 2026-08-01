import '../../../../core/utils/date_formatter.dart';
import '../../../tournament/domain/entities/tournament.dart';
import '../../../tournament/domain/repositories/registration_repository.dart';
import '../../../tournament/domain/repositories/tournament_repository.dart';
import '../../domain/entities/player_slot.dart';
import '../../domain/entities/roster_player.dart';
import '../../domain/entities/tee_group.dart';
import '../../domain/entities/tee_sheet.dart';
import '../../domain/repositories/tee_sheet_repository.dart';

/// In-memory tee sheet builder. Each tournament gets its own sheet, cached after
/// first build:
///   - the Riverbend Championship is a rich hand-seeded sheet (challenge pair,
///     guest, open slots) that shows off every builder feature;
///   - any other tournament is built from its [Tournament] event info plus a
///     roster pulled from that tournament's registered players.
///
/// Swap for an API implementation behind [TeeSheetRepository] when the backend
/// is ready; the widget layer never changes.
class MockTeeSheetRepository implements TeeSheetRepository {
  MockTeeSheetRepository(this._tournaments, this._registration);

  final TournamentRepository _tournaments;
  final RegistrationRepository _registration;

  final Map<String, TeeSheet> _sheets = {};

  Future<TeeSheet> _return(TeeSheet sheet) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return sheet;
  }

  Future<TeeSheet> _sheetFor(String tournamentId) async {
    final existing = _sheets[tournamentId];
    if (existing != null) return existing;
    final built = tournamentId == 't_riverbend' ? _riverbendSeed() : await _buildFrom(tournamentId);
    _sheets[tournamentId] = built;
    return built;
  }

  @override
  Future<TeeSheet> getTeeSheet(String tournamentId) async => _return(await _sheetFor(tournamentId));

  @override
  Future<TeeSheet> assignPlayer({
    required String tournamentId,
    required String playerId,
    required int groupNumber,
    required SlotPosition position,
  }) async {
    final sheet = await _sheetFor(tournamentId);
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

    return _store(sheet.copyWith(groups: groups, roster: roster));
  }

  @override
  Future<TeeSheet> unassignSlot({
    required String tournamentId,
    required int groupNumber,
    required SlotPosition position,
  }) async {
    final sheet = await _sheetFor(tournamentId);
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

    return _store(sheet.copyWith(groups: groups, roster: roster));
  }

  @override
  Future<TeeSheet> changeGroupTeeTime({
    required String tournamentId,
    required int groupNumber,
    required String teeTime,
  }) async {
    final sheet = await _sheetFor(tournamentId);
    final groups = sheet.groups
        .map((g) => g.groupNumber == groupNumber ? g.copyWith(teeTime: teeTime) : g)
        .toList();
    return _store(sheet.copyWith(groups: groups));
  }

  @override
  Future<TeeSheet> addGuest({
    required String tournamentId,
    required int groupNumber,
    required SlotPosition position,
    required String guestName,
  }) async {
    final sheet = await _sheetFor(tournamentId);
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

    return _store(sheet.copyWith(groups: groups, roster: roster));
  }

  @override
  Future<TeeSheet> saveDraft(TeeSheet sheet) => _store(sheet.copyWith(status: TeeSheetStatus.draft));

  @override
  Future<TeeSheet> publish(String tournamentId) async {
    final sheet = await _sheetFor(tournamentId);
    return _store(sheet.copyWith(status: TeeSheetStatus.published));
  }

  @override
  Future<void> emailToCourse(String tournamentId) async {
    // Real implementation hands off to the backend mail service; here we just
    // simulate the round-trip.
    await Future.delayed(const Duration(milliseconds: 250));
  }

  Future<TeeSheet> _store(TeeSheet sheet) {
    _sheets[sheet.tournamentId] = sheet;
    return _return(sheet);
  }

  RosterPlayer? _findInRoster(List<RosterPlayer> roster, String id) {
    for (final p in roster) {
      if (p.id == id) return p;
    }
    return null;
  }

  // --- Building a sheet from a tournament ----------------------------------

  Future<TeeSheet> _buildFrom(String tournamentId) async {
    final t = await _tournaments.getTournament(tournamentId);
    if (t == null) return _riverbendSeed();

    final names = await _registration.registeredPlayers(tournamentId);
    final roster = [
      for (var i = 0; i < names.length; i++)
        RosterPlayer(id: 'p$i', name: names[i], clubHandicap: _handicapFor(names[i])),
    ];

    // Start with a handful of empty groups. Shotgun Start places each group on a
    // hole sharing the single start time; Regular Start spaces them by interval
    // off hole 1. The admin drags the roster in and can add more as needed.
    final isShotgun = t.startType == StartType.shotgun;
    final groups = [
      for (var g = 1; g <= 4; g++)
        TeeGroup(
          groupNumber: g,
          teeTime: isShotgun
              ? t.firstTeeTime
              : _formatTime(t.teeOff.add(Duration(minutes: t.intervalMinutes * (g - 1)))),
          startingHole: isShotgun ? g : null,
          slots: _emptySlots,
        ),
    ];

    return TeeSheet(
      tournamentId: t.id,
      tournamentName: t.name,
      clubName: t.clubName,
      courseName: t.courseName,
      date: formatShortDate(t.date),
      firstTeeTime: t.firstTeeTime,
      intervalMinutes: t.intervalMinutes,
      status: TeeSheetStatus.draft,
      isShotgun: isShotgun,
      groups: groups,
      roster: roster,
      golfCourseEmail: t.golfCourseEmail,
    );
  }

  static const List<PlayerSlot> _emptySlots = [
    PlayerSlot.open(SlotPosition.a),
    PlayerSlot.open(SlotPosition.b),
    PlayerSlot.open(SlotPosition.c),
    PlayerSlot.open(SlotPosition.d),
  ];

  // Club handicaps for the seeded player pool; unknown names fall back to 12.0.
  static const Map<String, double> _handicaps = {
    'Marcus Thompson': 8.2,
    'Priya Kapoor': 11.0,
    'Sam Ortiz': 19.4,
    'Erin Walsh': 6.7,
    'Dana Reyes': 14.6,
    'Jordan Blake': 8.1,
    'Casey Nguyen': 9.4,
    'Devon Lee': 5.2,
    'Riley Foster': 10.2,
    'Alex Rivera': 3.7,
    'Taylor Brooks': 22.3,
    'Jahid': 7.4,
  };

  static double _handicapFor(String name) => _handicaps[name] ?? 12.0;

  static String _formatTime(DateTime dt) {
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    var hour = dt.hour % 12;
    if (hour == 0) hour = 12;
    return '$hour:${dt.minute.toString().padLeft(2, '0')} $period';
  }

  static TeeSheet _riverbendSeed() {
    // The logged-in user and their confirmed challenge opponent share pair id
    // 'cp1', so both slots render the gold Challenge badge.
    const jahid = RosterPlayer(
        id: 'u_jahid', name: 'Jahid', clubHandicap: 12.0, challengePairId: 'cp1');
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
