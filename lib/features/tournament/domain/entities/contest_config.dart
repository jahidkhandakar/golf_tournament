import 'package:equatable/equatable.dart';

/// How side-game money pays out. Chosen by the tournament creator at setup and
/// applies to skins and KPs the same way (and long drives in special events).
///
///   poolSplit: the pot divides evenly among the holes actually won. A 500
///              skins pot with 4 skins won pays 125 per skin. A 200 KP pot
///              with 2 KPs won pays 100 each.
///   carryover: each eligible hole carries a nominal value (pot divided by
///              eligible holes). An unwon hole rolls its value into the next
///              eligible hole, so a 50 KP that goes unwon makes the next KP
///              worth 100. Any value left unclaimed after the last hole splits
///              evenly among the winners already on the board.
enum PayoutMode { poolSplit, carryover }

/// Player categories for KPs and long drives. Regular club tournaments
/// (weekly gaggles) run everything as one open category. Special events (end
/// of year, sponsored) split into the four categories below and add long
/// drives.
enum ContestCategory { open, men, seniorMen, women, seniorWomen }

extension ContestCategoryX on ContestCategory {
  String get label {
    switch (this) {
      case ContestCategory.open:
        return 'Open';
      case ContestCategory.men:
        return 'Men';
      case ContestCategory.seniorMen:
        return 'Senior Men';
      case ContestCategory.women:
        return 'Women';
      case ContestCategory.seniorWomen:
        return 'Senior Women';
    }
  }
}

/// Side-game setup for a tournament: the course's hole pars, which holes run
/// KPs and long drives, the payout mode, and the pots collected. Entered by
/// the creator at setup; pars are editable on the entry screen if the course
/// data was off.
class ContestConfig extends Equatable {
  const ContestConfig({
    required this.holePars,
    this.kpHoles = const [],
    this.longDriveHoles = const [],
    this.payoutMode = PayoutMode.poolSplit,
    this.skinsPot = 0,
    this.kpPot = 0,
    this.longDrivePot = 0,
    this.useCategories = false,
    this.skinsDeductMidPercent = 0,
    this.skinsDeductPlusPercent = 0,
    this.kpLiveEnabled = true,
    this.guestsInSideGames = false,
    this.skinsOptOut = const {},
    this.kpOptOut = const {},
    this.guests = const {},
  });

  /// Per-player participation: players opted out of skins or KPs. Default is
  /// everyone in. Managed from the tee-box tap list before the round.
  /// Non-participants can't win or cut a hole. KP-out players can still
  /// measure for a teammate.
  final Set<String> skinsOptOut;
  final Set<String> kpOptOut;

  /// Course-backfill guests in this tournament. When [guestsInSideGames] is
  /// off (default) they are invisible to the skins engine and KP boards — they
  /// can't win and can't cut a hole — matching the server-side rule.
  final Set<String> guests;

  /// Par for holes 1 to 18 in order. Needed for skins: birdie or better is
  /// only knowable against the hole's par.
  final List<int> holePars;

  /// Holes running closest-to-the-pin placards (normally the par 3s).
  final List<int> kpHoles;

  /// Holes running long-drive placards. Special events only.
  final List<int> longDriveHoles;

  final PayoutMode payoutMode;

  /// Money collected for each game, in whole dollars.
  final int skinsPot;
  final int kpPot;
  final int longDrivePot;

  /// False for weekly gaggles (everyone competes in one open category). True
  /// for special events, which split KPs and long drives into Men, Senior
  /// Men, Women, Senior Women.
  final bool useCategories;

  /// Skins deduction for winners with a club handicap from 0 to 5.5. Zero is
  /// off. Allowed values run 10 to 50 in steps of 5, set by the creator and
  /// adjustable any time until results go final.
  final int skinsDeductMidPercent;

  /// Skins deduction for winners with a plus handicap (below zero). Same
  /// options as the mid band.
  final int skinsDeductPlusPercent;

  /// The selectable deduction options: off, then 10 to 50 percent in steps
  /// of 5.
  /// KP Live: on-course measuring with photo proof. On by default; creator
  /// can switch to placard entry only.
  final bool kpLiveEnabled;

  /// Guests compete in side games. Default off — course-backfill strangers
  /// shouldn't win members' money unless they bought in.
  final bool guestsInSideGames;

  static const List<int> deductionOptions = [0, 10, 15, 20, 25, 30, 35, 40, 45, 50];

  int parFor(int hole) =>
      (hole >= 1 && hole <= holePars.length) ? holePars[hole - 1] : 4;

  /// The category slots each KP or long-drive hole offers under this config.
  List<ContestCategory> get categories => useCategories
      ? const [
          ContestCategory.men,
          ContestCategory.seniorMen,
          ContestCategory.women,
          ContestCategory.seniorWomen,
        ]
      : const [ContestCategory.open];

  static List<int> defaultPars() =>
      const [4, 4, 3, 5, 4, 4, 3, 4, 5, 4, 3, 4, 5, 4, 4, 3, 4, 5];

  @override
  List<Object?> get props => [
        holePars,
        kpHoles,
        longDriveHoles,
        payoutMode,
        skinsPot,
        kpPot,
        longDrivePot,
        useCategories,
        skinsDeductMidPercent,
        skinsDeductPlusPercent,
        kpLiveEnabled,
        guestsInSideGames,
        skinsOptOut,
        kpOptOut,
        guests,
      ];

  /// Whether [player] competes in skins: not opted out, and (when guests are
  /// excluded) not a guest. Mirrors the server-side participation rule.
  bool participatesInSkins(String player) =>
      !skinsOptOut.contains(player) &&
      (guestsInSideGames || !guests.contains(player));

  /// Whether [player] may be recorded as a KP / long-drive winner. KP-out
  /// players can still measure for a teammate — this only blocks winning.
  bool canWinContest(String player) =>
      !kpOptOut.contains(player) &&
      (guestsInSideGames || !guests.contains(player));
}

/// A recorded KP or long-drive winner: the players write their names on the
/// placard out on the course, and whoever enters results copies the final
/// name into the right category slot.
class ContestWinner extends Equatable {
  const ContestWinner({
    required this.hole,
    required this.category,
    required this.playerName,
    this.isLongDrive = false,
    this.distance,
  });

  final int hole;
  final ContestCategory category;
  final String playerName;
  final bool isLongDrive;

  /// Optional measurement written on the placard (feet for KP, yards for LD).
  final String? distance;

  @override
  List<Object?> get props => [hole, category, playerName, isLongDrive, distance];
}
