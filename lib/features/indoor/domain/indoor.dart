import 'package:flutter/foundation.dart';

/// Indoor golf, revised flow. Season leagues run 3 to 18 weeks, one Round per
/// week (Mon 00:00 to Sun 23:59). Creation requires WEEK 1's course only;
/// later weeks are fillable or editable anytime until that week publishes.
/// One indoor add-on price covers league creation; public listing is an
/// approval on top, not a separate product. Witness verification ships in
/// two phases: check-in plus mutual close-confirmation first, the silent
/// random mid-session check as backend phase 2. Feed is CREATOR-ONLY
/// everywhere, indoor and outdoor, sub-admins read like everyone else.
/// Friend groups and In/Out replies are ONE invite system shared with
/// outdoor Pickups, built once. Sims and hours are NOT league-creation
/// fields: they are entered per booking when a player books their week at the
/// front desk. The weekly course rotation, with each course's rating and
/// slope, is set at creation and feeds the Indoor Handicap all season.
class WeekCourse {
  WeekCourse({required this.week, this.course = '', this.rating = 72.0, this.slope = 113});
  final int week;
  String course;
  double rating;
  int slope;
}

/// A front-desk booking: which sim, how many players, how many hours.
class SimBookingEntry {
  SimBookingEntry({required this.week, required this.sim, required this.players, required this.hours});
  final int week; final int sim; final List<String> players; final int hours;
}

class FlightMember {
  FlightMember({required this.player, this.indoorHandicap, this.flight, this.totalScore = 0, this.roundsPlayed = 0});
  final String player;
  double? indoorHandicap; int? flight;
  /// Season standing is TOTAL SCORE, golf style: admin enters weekly scores,
  /// totals accumulate, lowest total leads.
  int totalScore; int roundsPlayed;
  bool get established => roundsPlayed >= 3;
}

enum WitnessStatus { pending, verified, adminVerified, failed, overridden }

class LeagueRound {
  LeagueRound({required this.player, required this.weekNumber, required this.gross,
    this.witness, this.status = WitnessStatus.pending, this.isMakeup = false, this.net, this.skinsIn = false, this.kpIn = false});
  final String player; final int weekNumber; final int gross; final double? net;
  /// Witness: a checked-in playing league member of the same session. Solo
  /// bookings: the admin may verify instead, physically at the sim, passing
  /// the same proximity checks, verify-only. Screen photos count only when
  /// the verifier takes and sends them.
  String? witness; WitnessStatus status;
  /// Makeups (any time up to the last week) count for season prizes only:
  /// never skins, never weekly prizes. Banked rounds are normal rounds.
  final bool isMakeup;
  /// Entered weekly at the front desk at booking; shown as tags on result cards.
  final bool skinsIn; final bool kpIn;
  bool get skinsEligible => !isMakeup &&
      (status == WitnessStatus.verified || status == WitnessStatus.adminVerified || status == WitnessStatus.overridden);
}

/// One skins winner row: name, hole and score, amount won.
/// Weekly prize row: low gross or low net winner in a flight.
class WeeklyPrize { const WeeklyPrize(this.flight, this.type, this.player, this.score, this.prize);
  final int flight; final String type; final String player; final int score;
  /// Admin free text set when building the league, e.g. 50 range balls gift card.
  final String prize; }

class SkinResult { const SkinResult(this.player, this.hole, this.score, this.amount, [this.label = '']);
  final String player; final int hole; final int score; final double amount;
  /// e.g. Birdie, Eagle, Albatross, Hole in one.
  final String label; }
/// One KP row: name, hole, distance, prize.
class KpResult { const KpResult(this.player, this.hole, this.distanceFeet, this.prize);
  final String player; final int hole; final double distanceFeet; final double prize; }

class IndoorLeague {
  IndoorLeague({required this.id, required this.name, required this.facilityName,
    required this.seasonWeeks, this.entryFeeNote = '', this.skinsOn = true,
    this.allowScreenPhotos = false, this.midSeasonPrizes = false, this.showAmounts = false,
    this.entryCutoffWeek = 0, this.deductMid = 0, this.deductPlus = 0,
    this.isPublic = false, this.publicApproved = false, this.makeupCutoffWeeksBehind = 0}) :
    courses = [for (var w = 1; w <= seasonWeeks; w++) WeekCourse(week: w)];
  final String id; final String name; final String facilityName;
  /// 3 to 18 weeks.
  final int seasonWeeks;
  final String entryFeeNote; final bool skinsOn; final bool allowScreenPhotos;
  final bool midSeasonPrizes; final bool showAmounts;
  /// Entry stays open at the creator's discretion; default mid-season.
  final int entryCutoffWeek;

  /// Two paid categories, indoor-only fees separate from outdoor. Private:
  /// pay and go, invite-only, viewable by invited users anywhere in the world
  /// (cross-country play; the verifier's photo result goes to the admin).
  /// Public: reserved for simulator facility managers, listed to every user
  /// in the 60-mile zone, and requires GGW admin verification after payment.
  /// Until approved it behaves as private.
  final bool isPublic; bool publicApproved;

  /// Makeup deadline, creator's choice. 0 (default) = makeups allowed to the
  /// end of the league, because a member who paid and had life happen should
  /// not be locked out. A positive N = fall more than N weeks behind and the
  /// remaining missed rounds forfeit. Season-prizes-only rule still applies.
  final int makeupCutoffWeeksBehind;
  final int deductMid; final int deductPlus;
  final List<WeekCourse> courses;
  final List<FlightMember> members = [];
  final List<LeagueRound> rounds = [];
  final List<SimBookingEntry> bookings = [];
  int currentWeek = 1;

  /// Weeks whose results the admin has published. Scores entered any time,
  /// visible to members only after publish. Publish window: Sunday night to
  /// Tuesday 1800. Deadline shown to users: Tuesday 1800.
  final Set<int> publishedWeeks = {};

  /// Weekly prize rows entered by the admin at publish.
  final Map<int, List<SkinResult>> weekSkins = {};
  final Map<int, List<KpResult>> weekKps = {};
  final Map<int, List<WeeklyPrize>> weekPrizes = {};

  /// Per-player missed rounds, evaluated only after a week is PUBLISHED (not
  /// at the week deadline): players may play before deadline and forget to
  /// send scores, and timestamps or the front desk prove it, so nothing is
  /// missed until the admin publishes without a score for them. Includes the
  /// course name so the player knows what to play at the makeup. Shown on the
  /// player's own card and to admin; admin also sees the full missed list.
  List<WeekCourse> missedFor(String player) => [
        for (final w in publishedWeeks)
          if (!rounds.any((r) => r.player == player && r.weekNumber == w))
            courses[w - 1]
      ];

  /// Admin view: every player with missed rounds.
  Map<String, List<WeekCourse>> get missedByPlayer => {
        for (final m in members)
          if (missedFor(m.player).isNotEmpty) m.player: missedFor(m.player)
      };
}

/// One-time game: Sim Social Round. Skins-or-casual, sims and hours entered
/// at creation, open to invited non-league players.
class CasualRound {
  CasualRound({required this.id, required this.name, required this.facilityName,
    required this.withSkins, required this.sims, required this.hours, this.extraPerSim = false, this.startTime});
  final String id; final String name; final String facilityName; final bool withSkins;
  final DateTime? startTime;
  final int sims; final int hours; final bool extraPerSim;

  /// Private invites reply In or Out (public socials take no replies, anyone
  /// joins). In adds the player to the visible list everyone invited can see,
  /// Out included. Status changeable until the deadline, so someone can jump
  /// back in to even the numbers.
  final Map<String, String> invitedReplies = {};
  int get capacity => sims * hours + (extraPerSim ? sims : 0);

  /// Nobody can join after start time. The listing stays visible for 3 hours
  /// past start so a late-starting group can see who is missing, then it is
  /// deleted forever: no stats are kept for Sim Socials, so nothing archives.
  bool get joinable => startTime == null || DateTime.now().isBefore(startTime!);
  bool get expired => startTime != null && DateTime.now().isAfter(startTime!.add(const Duration(hours: 3)));
}

/// App-wide simulator course directory: first entry saves name, rating and
/// slope for everyone; later leagues confirm the numbers or edit their own copy.
class CourseDirectory {
  static final Map<String, (double, int)> courses = {};
  static void save(String n, double r, int sl) { if (n.trim().isNotEmpty) courses[n.trim()] = (r, sl); }
}

/// Saved friend groups, indoor and outdoor, for private Sim Social or Pickup
/// invites. Invite page shows accepted and "can't play" responses.
class FriendGroup {
  FriendGroup({required this.name, required this.members});
  final String name; final List<String> members;
}

class IndoorState extends ChangeNotifier {
  final List<FriendGroup> friendGroups = [];
  final List<IndoorLeague> leagues = [];
  final List<CasualRound> casuals = [];
  IndoorLeague addLeague(IndoorLeague l) { leagues.add(l); notifyListeners(); return l; }
  CasualRound addCasual(CasualRound c) { casuals.add(c); notifyListeners(); return c; }
  /// Purge run: permanently removes expired Sim Socials. Backend runs this on
  /// a schedule; the mock filters on read.
  void purgeExpired() { casuals.removeWhere((c) => c.expired); notifyListeners(); }
  void addBooking(IndoorLeague l, SimBookingEntry b) { l.bookings.add(b); notifyListeners(); }
  void submitRound(IndoorLeague l, LeagueRound r) {
    l.rounds.add(r);
    final m = l.members.firstWhere((x) => x.player == r.player, orElse: () {
      final nm = FlightMember(player: r.player); l.members.add(nm); return nm; });
    m.roundsPlayed += 1; notifyListeners();
  }
}
