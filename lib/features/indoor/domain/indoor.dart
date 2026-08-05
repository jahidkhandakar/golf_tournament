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
class IndoorLeague {
  IndoorLeague({
    required this.id,
    required this.name,
    required this.facilityName,
    required this.booking,
    this.entryFeeNote = '',
    this.totalRounds = 10,
    this.startedWeeksAgo = 0,
  });
  final String id;
  final String name;
  final String facilityName;
  final SimBooking booking;
  final String entryFeeNote;
  final int totalRounds;
  final int startedWeeksAgo;

  final List<FlightMember> members = [];
  final List<LeagueRound> rounds = [];

  /// Entry closes 3 weeks in: the 3-games-per-week ceiling makes catching up
  /// impossible after that.
  bool get entryOpen => startedWeeksAgo <= 3;
}

class IndoorState extends ChangeNotifier {
  final List<IndoorLeague> leagues = [];

  IndoorLeague createLeague({
    required String name,
    required String facilityName,
    required SimBooking booking,
    String entryFeeNote = '',
  }) {
    final league = IndoorLeague(
      id: 'league_${leagues.length + 1}',
      name: name,
      facilityName: facilityName,
      booking: booking,
      entryFeeNote: entryFeeNote,
    );
    leagues.add(league);
    notifyListeners();
    return league;
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
