import 'package:equatable/equatable.dart';

import 'roster_player.dart';
import 'tee_group.dart';

/// Draft vs published (§5.4). Save Draft stores the sheet privately; Publish
/// makes it visible to every registered player in the app.
enum TeeSheetStatus { draft, published }

/// The whole tee sheet a Club Creator / sub-admin builds for one tournament:
/// event info at the top, the ordered list of tee-time [groups], and the
/// [roster] of registered players not yet placed into a slot (§5).
class TeeSheet extends Equatable {
  const TeeSheet({
    required this.tournamentId,
    required this.tournamentName,
    required this.clubName,
    required this.courseName,
    required this.date,
    required this.firstTeeTime,
    required this.intervalMinutes,
    required this.status,
    required this.groups,
    required this.roster,
    this.golfCourseEmail,
  });

  final String tournamentId;
  final String tournamentName;

  /// The club running this tournament — used to gate the builder to that club's
  /// Creator / sub-admins.
  final String clubName;
  final String courseName;
  final String date;

  /// First tee time, e.g. `7:10 AM`.
  final String firstTeeTime;

  /// Minutes between consecutive tee times (10 in the client example, adjustable).
  final int intervalMinutes;

  final TeeSheetStatus status;

  /// Tee-time groups in order, one per tee time.
  final List<TeeGroup> groups;

  /// Registered players not yet assigned to a slot — the roster panel (§5.2).
  final List<RosterPlayer> roster;

  /// Target for the "Email to Course" action (§5.5). May be null until set on
  /// the tournament.
  final String? golfCourseEmail;

  bool get isPublished => status == TeeSheetStatus.published;

  /// Total occupied slots (players + guests) across all groups.
  int get assignedCount =>
      groups.fold(0, (sum, g) => sum + g.slots.where((s) => !s.isOpen).length);

  /// Total slot capacity of the sheet as currently laid out (4 × group count).
  int get slotCapacity => groups.length * 4;

  TeeSheet copyWith({
    TeeSheetStatus? status,
    List<TeeGroup>? groups,
    List<RosterPlayer>? roster,
    String? golfCourseEmail,
  }) =>
      TeeSheet(
        tournamentId: tournamentId,
        tournamentName: tournamentName,
        clubName: clubName,
        courseName: courseName,
        date: date,
        firstTeeTime: firstTeeTime,
        intervalMinutes: intervalMinutes,
        status: status ?? this.status,
        groups: groups ?? this.groups,
        roster: roster ?? this.roster,
        golfCourseEmail: golfCourseEmail ?? this.golfCourseEmail,
      );

  @override
  List<Object?> get props => [
        tournamentId,
        tournamentName,
        clubName,
        courseName,
        date,
        firstTeeTime,
        intervalMinutes,
        status,
        groups,
        roster,
        golfCourseEmail,
      ];
}
