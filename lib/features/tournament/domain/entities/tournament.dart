import 'package:equatable/equatable.dart';

import 'contest_config.dart';

/// Lifecycle of a tournament. Roster locks 48h before the first tee time (§2);
/// completed once scores are submitted (§6).
enum TournamentStatus { open, rosterLocked, completed }

/// How the field starts the round. Regular Start (the default, most
/// tournaments): every group starts at hole 1 at a set interval, capacity is
/// groups x 4. Shotgun Start: everyone starts at the same moment on different
/// holes, capacity is tee boxes x teams per tee box x 4 with a ceiling of 216.
enum StartType { regular, shotgun }

/// A club-run tournament created by a Club Creator / sub-admin.
///
/// Capacity is tee-box based, not a flat number (§1): each tee box (hole) holds
/// [teamsPerTeeBox] teams of [playersPerTeam]. An 18-hole course therefore maxes
/// at 18 × 3 × 4 = 216 players. Fewer than [minPlayers] isn't a tournament — it's
/// a Small Outing.
class Tournament extends Equatable {
  const Tournament({
    required this.id,
    required this.name,
    required this.clubName,
    required this.format,
    required this.courseName,
    this.zone,
    this.contests,
    required this.date,
    required this.firstTeeTime,
    required this.teeOff,
    required this.intervalMinutes,
    this.startType = StartType.regular,
    this.groupsCount = 10,
    this.teeBoxes = maxTeeBoxes,
    this.teamsPerTeeBox = maxTeamsPerTeeBox,
    this.standbyPlayers = const [],
    this.subRequests = const [],
    this.showAmounts = false,
    this.courseCountry = 'US',
    this.templateName,
    this.golfCourseEmail,
    this.registeredPlayers = 0,
    this.status = TournamentStatus.open,
  });

  final String id;
  final String name;
  final String clubName;
  final String format;
  final String courseName;

  /// The city zone this tournament sits in (matches LocationState zone labels).
  /// Free users joining an event outside their home zone consume a travel
  /// trial. Null is treated as the user's home zone.
  final String? zone;

  /// Side-game setup: hole pars, KP and long-drive holes, payout mode, pots.
  /// Null until the creator configures the games; the entry screen falls back
  /// to defaults so score entry is never blocked.
  final ContestConfig? contests;

  final DateTime date;

  /// First tee time for display, e.g. `7:10 AM`.
  final String firstTeeTime;

  /// The exact first-tee moment — the anchor for the 48h / 24h cutoffs (§2).
  final DateTime teeOff;

  /// Minutes between consecutive tee times (Regular Start only).
  final int intervalMinutes;

  /// How the field starts: Regular (groups off hole 1 at intervals) or
  /// Shotgun (simultaneous start across tee boxes).
  final StartType startType;

  /// Number of 4 player groups (Regular Start only). Capacity is groups x 4.
  final int groupsCount;

  /// Tee boxes in play (1–18) and teams per tee box (1–3) — together these set
  /// the capacity.
  final int teeBoxes;
  final int teamsPerTeeBox;

  /// Standby list: FIFO order. Staff promotes into the roster at any time,
  /// bypassing the 48-hour lock. Travel trial consumed on promotion only.
  /// A replacement inherits nothing from the player they replaced.
  final List<String> standbyPlayers;

  /// Sub requests: a registered player who cannot make it requests a sub;
  /// the open slot is offered to the standby list first, in order, before
  /// staff fill it manually. The requester keeps no claim on the slot.
  final List<String> subRequests;

  /// Creator display toggle for money amounts. Default off. When on, amounts
  /// show during the round and purge 24 hours after Final — permanently, no
  /// archive, no export. Names survive.
  final bool showAmounts;

  /// The golf course's country, used for amateur-status cap lookup. Course
  /// country governs because that's where the competition physically happens.
  final String courseCountry;

  /// If this tournament was created from a saved template, or if the creator
  /// saved these settings as a template for reuse.
  final String? templateName;

  final String? golfCourseEmail;
  final int registeredPlayers;
  final TournamentStatus status;

  static const int playersPerTeam = 4;
  static const int maxTeeBoxes = 18;
  static const int maxTeamsPerTeeBox = 3;
  static const int minPlayers = 8; // fewer than this is a Small Outing
  static const int maxPlayers = maxTeeBoxes * maxTeamsPerTeeBox * playersPerTeam; // 216

  /// Shotgun capacity for a tee-box / team layout.
  static int capacityFor(int teeBoxes, int teamsPerTeeBox) =>
      teeBoxes * teamsPerTeeBox * playersPerTeam;

  /// Regular Start capacity for a group count.
  static int capacityForGroups(int groups) => groups * playersPerTeam;

  int get capacity => startType == StartType.shotgun
      ? capacityFor(teeBoxes, teamsPerTeeBox)
      : capacityForGroups(groupsCount);

  bool get isFull => registeredPlayers >= capacity;

  // --- Timing cutoffs (§2) -------------------------------------------------
  // 48h before tee off the roster locks (no new registrations, withdrawals, or
  // challenge/pairing requests); 24h before is the pairing-preference deadline.
  static const Duration rosterLockLead = Duration(hours: 48);
  static const Duration pairingDeadlineLead = Duration(hours: 24);

  DateTime get rosterLockAt => teeOff.subtract(rosterLockLead);
  DateTime get pairingDeadlineAt => teeOff.subtract(pairingDeadlineLead);

  /// Roster is locked once we're within 48h of tee off — no new registrations,
  /// withdrawals, or challenge/pairing requests.
  bool get isRosterLocked => !DateTime.now().isBefore(rosterLockAt);

  /// Pairing-preference submission closes 24h before tee off.
  bool get isPairingClosed => !DateTime.now().isBefore(pairingDeadlineAt);

  /// Time remaining until the roster locks (negative once locked).
  Duration get timeUntilRosterLock => rosterLockAt.difference(DateTime.now());

  /// Time remaining until the pairing-preference deadline.
  Duration get timeUntilPairingDeadline => pairingDeadlineAt.difference(DateTime.now());

  /// A shotgun layout is valid when it seats between [minPlayers] and
  /// [maxPlayers] within the tee-box / team limits.
  static bool isValidLayout(int teeBoxes, int teamsPerTeeBox) {
    if (teeBoxes < 1 || teeBoxes > maxTeeBoxes) return false;
    if (teamsPerTeeBox < 1 || teamsPerTeeBox > maxTeamsPerTeeBox) return false;
    final capacity = capacityFor(teeBoxes, teamsPerTeeBox);
    return capacity >= minPlayers && capacity <= maxPlayers;
  }

  /// A Regular Start group count is valid when it seats between [minPlayers]
  /// and [maxPlayers].
  static bool isValidGroups(int groups) {
    final capacity = capacityForGroups(groups);
    return capacity >= minPlayers && capacity <= maxPlayers;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        clubName,
        format,
        courseName,
        zone,
        contests,
        date,
        firstTeeTime,
        teeOff,
        intervalMinutes,
        startType,
        groupsCount,
        teeBoxes,
        teamsPerTeeBox,
        standbyPlayers,
        subRequests,
        showAmounts,
        courseCountry,
        templateName,
        golfCourseEmail,
        registeredPlayers,
        status,
      ];
}
