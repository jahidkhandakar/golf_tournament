import 'package:flutter/foundation.dart';

/// Indoor golf: simulator events and 10-round leagues. Indoor is a separate
/// world from outdoor by design (patent separation): its own unofficial
/// Indoor Handicap, no Top 50, no club ladders, nothing indoor ever attaches
/// to or mixes with outdoor records. Indoor leagues and games are standalone,
/// created by any user, never nested under an outdoor club.
///
/// One-time events are called Sim Social Rounds. League games are titled
/// Round 1 through Round 10.

/// Capacity: sims booked x hours per sim, always even by construction, with a
/// creator toggle allowing one extra player per sim (rarely finishable).
class SimBooking {
  const SimBooking({required this.sims, required this.hoursPerSim, this.allowExtraPerSim = false});
  final int sims;
  final int hoursPerSim;
  final bool allowExtraPerSim;
  int get capacity => sims * hoursPerSim + (allowExtraPerSim ? sims : 0);
}

/// A league member's flight allocation. Flights form after the first 3 rounds
/// establish the Indoor Handicap; the creator sets the flight order. Weekly
/// points, lowest score wins within each flight. Season end pays a net and a
/// gross winner per flight.
class FlightMember {
  FlightMember({required this.player, this.indoorHandicap, this.flight, this.points = 0, this.roundsPlayed = 0});
  final String player;
  double? indoorHandicap;
  int? flight;
  int points;
  int roundsPlayed;
  bool get established => roundsPlayed >= 3;
}

enum WitnessStatus { pending, verified, failed, overridden }

/// One league round on a player's card. Credited to the next unfilled week
/// (Monday through midnight Sunday). Max 3 games in a week when banking
/// ahead; unlimited makeups within a week when behind, capped by the 10-game
/// total. Late entry closes 3 weeks after the league starts.
class LeagueRound {
  LeagueRound({
    required this.player,
    required this.weekNumber,
    required this.gross,
    this.witness,
    this.status = WitnessStatus.pending,
  });
  final String player;
  final int weekNumber;
  final int gross;

  /// The witnessing league member. Must be a checked-in playing member of the
  /// same sim session: both players verify each other at session close. A
  /// witness who is not playing is not accepted.
  String? witness;

  /// Witness verification runs on three discrete proximity checks against the
  /// creator's pinned sim location: session check-in, one silent random-time
  /// mid-session check, and session close. Pass or fail plus timestamp only;
  /// no coordinates are ever stored, no movement history. An unverified round
  /// still counts for standings and season prizes but is not eligible for
  /// that week's skins. Creator can override for genuine failures.
  WitnessStatus status;

  bool get skinsEligible => status == WitnessStatus.verified || status == WitnessStatus.overridden;
}

/// A 10-round indoor league. Money follows the outdoor pattern exactly: the
/// app never collects or stores it. Entry fee is a display-only text line.
/// The creator enters the week's skins winners at week's end.
/// A one-time invite to a private league. The creator generates a code and
/// hands it to the invited player, who redeems it to join — no one can join a
/// private league on their own. Mirrors the private-club member-slot pattern.
class LeagueInvite {
  LeagueInvite({
    required this.code,
    required this.invitedName,
    this.redeemed = false,
  });

  final String code;
  String invitedName;
  bool redeemed;
}

class IndoorLeague {
  IndoorLeague({
    required this.id,
    required this.name,
    required this.facilityName,
    required this.booking,
    this.entryFeeNote = '',
    this.totalRounds = 10,
    this.startedWeeksAgo = 0,
    this.isPrivate = false,
    this.clubName,
    this.createdByMe = true,
  });
  final String id;
  final String name;
  final String facilityName;
  final SimBooking booking;
  final String entryFeeNote;
  final int totalRounds;
  final int startedWeeksAgo;

  /// Private leagues are invite-only and invisible to non-members — nobody can
  /// join on their own. Can stand alone or sit inside a private club ([clubName]).
  final bool isPrivate;
  final String? clubName;

  /// The logged-in user created this league (so they can see and manage it even
  /// when it's private).
  final bool createdByMe;

  final List<FlightMember> members = [];
  final List<LeagueRound> rounds = [];
  final List<LeagueInvite> invites = [];

  /// Entry closes 3 weeks in: the 3-games-per-week ceiling makes catching up
  /// impossible after that.
  bool get entryOpen => startedWeeksAgo <= 3;
}

/// A booked simulator session. The sim board replaces the tee sheet: one
/// column per simulator (bay), and the creator drags/assigns players into
/// bays and makes the teams. There is no self-pairing — only the session
/// creator arranges the bays. Displayed in the app only; no email to any
/// course. Used for both league sessions and one-time Sim Social Rounds.
class SimSession {
  SimSession({
    required this.id,
    required this.title,
    required this.booking,
    this.isSocialRound = false,
    List<String> roster = const [],
  }) : roster = [...roster];

  final String id;
  final String title;
  final SimBooking booking;

  /// Sim Social Rounds are one-time events, the only indoor format open to
  /// invited non-league players. League sessions are members only.
  final bool isSocialRound;

  /// Everyone booked into this session, whether or not they have a bay yet.
  final List<String> roster;

  /// bay index (0 .. sims-1) -> the players assigned to that simulator.
  final Map<int, List<String>> bays = {};

  int get bayCount => booking.sims;

  /// Players a single bay can hold: one per booked hour, plus one when the
  /// creator allowed an extra per sim.
  int get perBayCapacity => booking.hoursPerSim + (booking.allowExtraPerSim ? 1 : 0);

  List<String> playersInBay(int index) => List.unmodifiable(bays[index] ?? const []);

  bool isBayFull(int index) => (bays[index]?.length ?? 0) >= perBayCapacity;

  /// Players in the roster not yet placed in any bay.
  List<String> get unassigned {
    final placed = bays.values.expand((b) => b).toSet();
    return roster.where((p) => !placed.contains(p)).toList();
  }
}

class IndoorState extends ChangeNotifier {
  final List<IndoorLeague> leagues = [];
  final List<SimSession> sessions = [];

  SimSession createSession({
    required String title,
    required SimBooking booking,
    bool isSocialRound = false,
    List<String> roster = const [],
  }) {
    final session = SimSession(
      id: 'sim_${sessions.length + 1}',
      title: title,
      booking: booking,
      isSocialRound: isSocialRound,
      roster: roster,
    );
    sessions.add(session);
    notifyListeners();
    return session;
  }

  /// Move [player] into [bayIndex], removing them from any other bay first
  /// (reassignment). No-op when the target bay is full. Passing a negative
  /// [bayIndex] returns the player to the unassigned pool.
  void assignToBay(SimSession session, String player, int bayIndex) {
    for (final b in session.bays.values) {
      b.remove(player);
    }
    if (bayIndex >= 0 && bayIndex < session.bayCount && !session.isBayFull(bayIndex)) {
      session.bays.putIfAbsent(bayIndex, () => []).add(player);
    }
    if (!session.roster.contains(player)) session.roster.add(player);
    notifyListeners();
  }

  void addToRoster(SimSession session, String player) {
    if (player.isEmpty || session.roster.contains(player)) return;
    session.roster.add(player);
    notifyListeners();
  }


  IndoorLeague createLeague({
    required String name,
    required String facilityName,
    required SimBooking booking,
    String entryFeeNote = '',
    bool isPrivate = false,
    String? clubName,
  }) {
    final league = IndoorLeague(
      id: 'league_${leagues.length + 1}',
      name: name,
      facilityName: facilityName,
      booking: booking,
      entryFeeNote: entryFeeNote,
      isPrivate: isPrivate,
      clubName: clubName,
    );
    leagues.add(league);
    notifyListeners();
    return league;
  }

  /// Creator generates a one-time invite code for a private league.
  LeagueInvite createInvite(IndoorLeague league, String invitedName) {
    final invite = LeagueInvite(code: _generateCode(), invitedName: invitedName);
    league.invites.add(invite);
    notifyListeners();
    return invite;
  }

  /// Redeem an invite code to join a private league. Returns the league on
  /// success, null if the code is unknown or already used. This is the only way
  /// into a private league — there is no self-join.
  IndoorLeague? redeemInvite(String code, String memberName) {
    for (final league in leagues) {
      for (final invite in league.invites) {
        if (invite.code == code && !invite.redeemed) {
          invite.redeemed = true;
          if (!league.members.any((m) => m.player == memberName)) {
            league.members.add(FlightMember(player: memberName));
          }
          notifyListeners();
          return league;
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

  void submitRound(IndoorLeague league, LeagueRound round) {
    league.rounds.add(round);
    final m = league.members.firstWhere((x) => x.player == round.player,
        orElse: () {
      final nm = FlightMember(player: round.player);
      league.members.add(nm);
      return nm;
    });
    m.roundsPlayed += 1;
    notifyListeners();
  }

  void verifyRound(LeagueRound round, {required bool passedProximity}) {
    round.status = passedProximity ? WitnessStatus.verified : WitnessStatus.failed;
    notifyListeners();
  }

  void creatorOverride(LeagueRound round) {
    round.status = WitnessStatus.overridden;
    notifyListeners();
  }
}
