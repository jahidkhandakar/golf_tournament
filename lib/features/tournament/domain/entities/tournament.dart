import 'package:equatable/equatable.dart';

/// Lifecycle of a tournament. Roster locks 48h before the first tee time (§2);
/// completed once scores are submitted (§6).
enum TournamentStatus { open, rosterLocked, completed }

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
    required this.date,
    required this.firstTeeTime,
    required this.teeOff,
    required this.intervalMinutes,
    required this.teeBoxes,
    required this.teamsPerTeeBox,
    this.golfCourseEmail,
    this.registeredPlayers = 0,
    this.status = TournamentStatus.open,
  });

  final String id;
  final String name;
  final String clubName;
  final String format;
  final String courseName;
  final DateTime date;

  /// First tee time for display, e.g. `7:10 AM`.
  final String firstTeeTime;

  /// The exact first-tee moment — the anchor for the 48h / 24h cutoffs (§2).
  final DateTime teeOff;

  /// Minutes between consecutive tee times.
  final int intervalMinutes;

  /// Tee boxes in play (1–18) and teams per tee box (1–3) — together these set
  /// the capacity.
  final int teeBoxes;
  final int teamsPerTeeBox;

  final String? golfCourseEmail;
  final int registeredPlayers;
  final TournamentStatus status;

  static const int playersPerTeam = 4;
  static const int maxTeeBoxes = 18;
  static const int maxTeamsPerTeeBox = 3;
  static const int minPlayers = 8; // fewer than this is a Small Outing
  static const int maxPlayers = maxTeeBoxes * maxTeamsPerTeeBox * playersPerTeam; // 216

  /// Player capacity for the current tee-box / team layout.
  static int capacityFor(int teeBoxes, int teamsPerTeeBox) =>
      teeBoxes * teamsPerTeeBox * playersPerTeam;

  int get capacity => capacityFor(teeBoxes, teamsPerTeeBox);

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

  /// A layout is valid as a tournament when it seats between [minPlayers] and
  /// [maxPlayers] within the tee-box / team limits.
  static bool isValidLayout(int teeBoxes, int teamsPerTeeBox) {
    if (teeBoxes < 1 || teeBoxes > maxTeeBoxes) return false;
    if (teamsPerTeeBox < 1 || teamsPerTeeBox > maxTeamsPerTeeBox) return false;
    final capacity = capacityFor(teeBoxes, teamsPerTeeBox);
    return capacity >= minPlayers && capacity <= maxPlayers;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        clubName,
        format,
        courseName,
        date,
        firstTeeTime,
        teeOff,
        intervalMinutes,
        teeBoxes,
        teamsPerTeeBox,
        golfCourseEmail,
        registeredPlayers,
        status,
      ];
}
