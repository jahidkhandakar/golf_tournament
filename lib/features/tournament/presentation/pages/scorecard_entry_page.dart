import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/permission/club_role.dart';
import '../../../../core/permission/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/user/user_tier.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../top50/presentation/top50_ladder_controller.dart';
import '../../data/player_directory.dart';
import '../../domain/entities/contest_config.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/live_results.dart';
import '../../domain/repositories/challenge_approval_repository.dart';
import '../../domain/repositories/registration_repository.dart';

/// Live score entry for the Club Creator and sub-admins. Built for speed off a
/// paper card: pick the player, and the hole strip auto-advances after every
/// score. Scores land on the live results board the moment they are saved;
/// everything shows In Progress until Final Results is pressed, and only then
/// do the handicap, Top 50, Club Leaderboard, and challenge engines run.
class ScorecardEntryPage extends StatefulWidget {
  const ScorecardEntryPage({super.key, required this.tournament});

  final Tournament tournament;

  @override
  State<ScorecardEntryPage> createState() => _ScorecardEntryPageState();
}

class _ScorecardEntryPageState extends State<ScorecardEntryPage> {
  final RegistrationRepository _registration = GetIt.instance<RegistrationRepository>();
  final PermissionService _permission = GetIt.instance<PermissionService>();
  final LiveResultsRegistry _registry = GetIt.instance<LiveResultsRegistry>();

  LiveResults? _live;
  String? _player;
  int _hole = 1;
  bool _loading = true;

  ContestConfig get _config =>
      widget.tournament.contests ?? ContestConfig(holePars: ContestConfig.defaultPars());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final names = await _registration.registeredPlayers(widget.tournament.id);
    if (!mounted) return;
    setState(() {
      _live = _registry.of(
        widget.tournament.id,
        config: _config,
        players: names,
        handicaps: GetIt.instance<PlayerDirectory>().handicapsFor(names),
      );
      _player = names.isNotEmpty ? names.first : null;
      _loading = false;
    });
    _live!.addListener(_onLive);
  }

  void _onLive() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _live?.removeListener(_onLive);
    super.dispose();
  }

  bool get _isStaff => _permission.roleInClub(widget.tournament.clubName).isStaff;

  void _enter(int strokes) {
    final live = _live;
    final player = _player;
    if (live == null || player == null || live.isFinal) return;
    live.enterScore(player, _hole, strokes);
    if (_hole < 18) setState(() => _hole += 1);
  }

  /// Creator adjustable skins deduction bands, changeable any time until
  /// results go final. Winners at 5.6 and above always keep their full skin.
  Future<void> _editDeductions(LiveResults live) async {
    var mid = live.deductMidPercent;
    var plus = live.deductPlusPercent;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: const Text('Skins deductions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Deducted from winners in each handicap band and split among winners at 5.6 and above.'),
              const SizedBox(height: 14),
              Row(children: [
                const Expanded(child: Text('Handicap 0 to 5.5')),
                DropdownButton<int>(
                  value: mid,
                  items: [
                    for (final v in ContestConfig.deductionOptions)
                      DropdownMenuItem(value: v, child: Text(v == 0 ? 'Off' : '$v%')),
                  ],
                  onChanged: (v) => setDialog(() => mid = v ?? 0),
                ),
              ]),
              Row(children: [
                const Expanded(child: Text('Plus handicaps (below 0)')),
                DropdownButton<int>(
                  value: plus,
                  items: [
                    for (final v in ContestConfig.deductionOptions)
                      DropdownMenuItem(value: v, child: Text(v == 0 ? 'Off' : '$v%')),
                  ],
                  onChanged: (v) => setDialog(() => plus = v ?? 0),
                ),
              ]),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (saved == true) live.setDeductions(midPercent: mid, plusPercent: plus);
  }

  Future<void> _pressFinal() async {
    final live = _live;
    if (live == null) return;
    final missing = live.playersWithMissingHoles;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final results'),
        content: Text(missing.isEmpty
            ? 'Lock entry and publish these results as final? The handicap engine, Top 50, Club Leaderboard, and challenge outcomes all run from this.'
            : 'These players still have open holes:\n\n${missing.join(', ')}\n\nFinalize anyway? Open holes count as no score.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Finalize')),
        ],
      ),
    );
    if (proceed != true || !mounted) return;
    live.finalize();
    // Engine hook: resolve confirmed challenges from the final scores (§6). In
    // production the handicap + leaderboard engines also run here.
    await _resolveChallenges(live);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Results are final. Engines run from these scores.')),
    );
  }

  /// On finalize, each confirmed challenge resolves by lower final gross and
  /// moves the Top 50 ladder (§3, §6).
  Future<void> _resolveChallenges(LiveResults live) async {
    final repo = GetIt.instance<ChallengeApprovalRepository>();
    final ladder = GetIt.instance<Top50LadderController>();
    int? grossOf(String name) => live.holesEntered(name) > 0 ? live.total(name) : null;
    for (final c in await repo.confirmedFor(widget.tournament.id)) {
      final a = grossOf(c.challengerName);
      final b = grossOf(c.opponentName);
      if (a == null || b == null || a == b) continue;
      final challengerWon = a < b;
      ladder.recordResult(
        winnerName: challengerWon ? c.challengerName : c.opponentName,
        loserName: challengerWon ? c.opponentName : c.challengerName,
      );
      await repo.markResolved(c.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final live = _live;

    if (_loading || live == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_isStaff) {
      return Scaffold(
        appBar: AppBar(title: const Text('Score entry')),
        body: const Center(child: Text('Only the Club Creator or a sub-admin can enter scores.')),
      );
    }

    final par = _config.parFor(_hole);
    final player = _player;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Score entry'),
        actions: [
          if (!live.isFinal)
            IconButton(
              tooltip: 'Skins deductions',
              icon: const Icon(Icons.tune),
              onPressed: () => _editDeductions(live),
            ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(live, primaryText, secondaryText),
          const SizedBox(height: 14),
          _playerSelector(live, primaryText, secondaryText),
          const SizedBox(height: 14),
          _holeStrip(live, primaryText),
          const SizedBox(height: 10),
          Text('Hole $_hole  ·  Par $par', style: AppTextStyles.bodyBold(primaryText)),
          const SizedBox(height: 8),
          if (!live.isFinal) _scoreButtons(par),
          if (player != null) ...[
            const SizedBox(height: 14),
            _totalsRow(live, player, primaryText, secondaryText),
          ],
          const SizedBox(height: 20),
          _skinsPanel(live, primaryText, secondaryText),
          const SizedBox(height: 20),
          _placards(live, primaryText, secondaryText),
          const SizedBox(height: 24),
          if (!live.isFinal)
            ElevatedButton.icon(
              onPressed: _pressFinal,
              icon: const Icon(Icons.lock_outline),
              label: const Text('Final Results'),
            ),
        ],
          )),
          _SkinsStrip(
            live: live,
            onHoleTap: (hole) => setState(() => _hole = hole),
            onTrophy: () => _showWinnersSheet(context, live),
          ),
        ],
      ),
    );
  }

  Widget _header(LiveResults live, Color primaryText, Color secondaryText) {
    final t = widget.tournament;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.name, style: AppTextStyles.bodyBold(primaryText)),
                Text('${t.courseName} · ${t.clubName}', style: AppTextStyles.caption(secondaryText)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: live.isFinal ? AppColors.success : AppColors.gold,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              live.isFinal ? 'FINAL' : 'IN PROGRESS',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerSelector(LiveResults live, Color primaryText, Color secondaryText) {
    return DropdownButtonFormField<String>(
      initialValue: _player,
      decoration: const InputDecoration(labelText: 'Player', border: OutlineInputBorder()),
      items: [
        for (final p in live.players)
          DropdownMenuItem(
            value: p,
            child: Row(
              children: [
                Expanded(child: Text(p, overflow: TextOverflow.ellipsis)),
                _identityChips(p, secondaryText),
                const SizedBox(width: 6),
                Text('${live.holesEntered(p)}/18', style: AppTextStyles.caption(secondaryText)),
              ],
            ),
          ),
      ],
      onChanged: (v) => setState(() {
        _player = v;
        if (v != null) {
          final next = List.generate(18, (i) => i + 1)
              .firstWhere((h) => live.scoreFor(v, h) == 0, orElse: () => 18);
          _hole = next;
        }
      }),
    );
  }

  /// Gender and senior chips next to the name, so whoever is entering placard
  /// results knows which category slot a player belongs in. Data comes from
  /// the player's profile; mock lookup until profiles are wired per player.
  Widget _identityChips(String player, Color secondaryText) {
    final profile = _profileFor(player);
    final parts = <String>[];
    if (profile.gender == Gender.male) parts.add('M');
    if (profile.gender == Gender.female) parts.add('W');
    if (profile.isSenior) parts.add('Sr');
    if (parts.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(parts.join(' · '), style: AppTextStyles.caption(secondaryText)),
    );
  }

  UserProfile _profileFor(String player) {
    // Reads the player directory (each registrant's profile once wired), so
    // the chips reflect real profile data instead of guesses.
    final entry = GetIt.instance<PlayerDirectory>().lookup(player);
    return UserProfile(
      name: player,
      tier: UserTier.paid,
      gender: entry.gender,
      isSenior: entry.senior,
      clubHandicap: entry.handicap,
      homeClub: widget.tournament.clubName,
      currentTournament: widget.tournament.name,
      currentCourse: widget.tournament.courseName,
    );
  }

  Widget _holeStrip(LiveResults live, Color primaryText) {
    final player = _player;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 18,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final hole = i + 1;
          final entered = player != null && live.scoreFor(player, hole) > 0;
          final selected = hole == _hole;
          return ChoiceChip(
            label: Text(entered ? '$hole · ${live.scoreFor(player, hole)}' : '$hole'),
            selected: selected,
            selectedColor: AppColors.gold,
            onSelected: (_) => setState(() => _hole = hole),
            avatar: entered && !selected ? const Icon(Icons.check, size: 14) : null,
          );
        },
      ),
    );
  }

  Widget _scoreButtons(int par) {
    final labels = <({String label, int strokes})>[
      (label: 'Eagle', strokes: par - 2),
      (label: 'Birdie', strokes: par - 1),
      (label: 'Par', strokes: par),
      (label: 'Bogey', strokes: par + 1),
      (label: '+2', strokes: par + 2),
      (label: '+3', strokes: par + 3),
    ].where((e) => e.strokes >= 1).toList();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final e in labels)
          ElevatedButton(
            onPressed: () => _enter(e.strokes),
            child: Text('${e.label} (${e.strokes})'),
          ),
        OutlinedButton(
          onPressed: () async {
            final controller = TextEditingController();
            final v = await showDialog<int>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Hole $_hole strokes'),
                content: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(int.tryParse(controller.text)),
                    child: const Text('Save'),
                  ),
                ],
              ),
            );
            if (v != null && v >= 1) _enter(v);
          },
          child: const Text('Other'),
        ),
      ],
    );
  }

  Widget _totalsRow(LiveResults live, String player, Color primaryText, Color secondaryText) {
    Widget cell(String label, int value) => Expanded(
          child: Column(
            children: [
              Text(label, style: AppTextStyles.caption(secondaryText)),
              Text(value > 0 ? '$value' : '-', style: AppTextStyles.bodyBold(primaryText)),
            ],
          ),
        );
    return Row(
      children: [
        cell('Front 9', live.frontNine(player)),
        cell('Back 9', live.backNine(player)),
        cell('Total', live.total(player)),
        cell('Thru', live.holesEntered(player)),
      ],
    );
  }

  Widget _skinsPanel(LiveResults live, Color primaryText, Color secondaryText) {
    final skins = live.skins;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Skins (live, event wide)', style: AppTextStyles.bodyBold(primaryText)),
        const SizedBox(height: 6),
        if (skins.isEmpty)
          Text('No skins won yet. Birdie or better takes a hole outright; a lone par can claim an open hole.',
              style: AppTextStyles.caption(secondaryText))
        else
          for (final s in skins)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                'Hole ${s.hole} · ${s.winner} · ${s.winningScore} on par ${s.par}'
                '${s.wonWithPar ? ' (lone par)' : ''} · \$${s.value.toStringAsFixed(0)}',
                style: AppTextStyles.caption(secondaryText),
              ),
            ),
      ],
    );
  }

  Widget _placards(LiveResults live, Color primaryText, Color secondaryText) {
    final config = _config;
    if (config.kpHoles.isEmpty && config.longDriveHoles.isEmpty) {
      return Text('No KP or long drive holes configured for this event.',
          style: AppTextStyles.caption(secondaryText));
    }
    Widget section(String title, List<int> holes, bool isLd, Map<int, double> values) {
      if (holes.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyBold(primaryText)),
          const SizedBox(height: 6),
          for (final hole in holes)
            for (final cat in config.categories)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        'Hole $hole · ${cat.label}'
                        '${values.containsKey(hole) ? ' · \$${values[hole]!.toStringAsFixed(0)}' : ''}',
                        style: AppTextStyles.caption(secondaryText),
                      ),
                    ),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('From placard'),
                        value: _winnerName(live, hole, cat, isLd),
                        items: [
                          const DropdownMenuItem(value: '', child: Text('(none)')),
                          for (final p in live.players)
                            DropdownMenuItem(
                              value: p,
                              child: Row(
                                children: [
                                  Expanded(child: Text(p, overflow: TextOverflow.ellipsis)),
                                  _identityChips(p, secondaryText),
                                ],
                              ),
                            ),
                        ],
                        onChanged: live.isFinal
                            ? null
                            : (v) => live.recordContestWinner(ContestWinner(
                                  hole: hole,
                                  category: cat,
                                  playerName: v ?? '',
                                  isLongDrive: isLd,
                                )),
                      ),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 10),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        section('Closest to the pin', config.kpHoles, false, live.kpValues),
        section('Long drive', config.longDriveHoles, true, live.longDriveValues),
      ],
    );
  }

  String? _winnerName(LiveResults live, int hole, ContestCategory cat, bool isLd) {
    for (final w in live.contestWinners) {
      if (w.hole == hole && w.category == cat && w.isLongDrive == isLd) return w.playerName;
    }
    return null;
  }
}


/// The 18-hole skins status strip on the right edge of the score entry screen.
/// White = open (no scores yet), Green = currently winning (one outright best
/// at birdie or better), Red = cut (tied or no qualifying score). Tap a tile
/// to jump entry to that hole. Trophy tile at the bottom opens the winners
/// sheet. 44px wide, never shrinks the entry area.
class _SkinsStrip extends StatelessWidget {
  const _SkinsStrip({required this.live, required this.onHoleTap, required this.onTrophy});
  final LiveResults live;
  final void Function(int hole) onHoleTap;
  final VoidCallback onTrophy;

  @override
  Widget build(BuildContext context) {
    final skins = live.skins;
    final won = {for (final s in skins) s.hole};
    // Determine which holes are cut: scores exist but no skin won
    final scored = <int>{};
    for (final p in live.players) {
      final holes = live.holesForPlayer(p);
      for (var h = 0; h < 18; h++) {
        if (holes[h] > 0) scored.add(h + 1);
      }
    }

    return SizedBox(
      width: 44,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 18,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemBuilder: (context, i) {
                final hole = i + 1;
                final isWon = won.contains(hole);
                final isScored = scored.contains(hole);
                final isCut = isScored && !isWon;
                final color = isWon
                    ? const Color(0xFF2E7D32)
                    : isCut
                        ? const Color(0xFFCC4444)
                        : Colors.white;
                final textColor = isWon || isCut ? Colors.white : Colors.black87;
                return GestureDetector(
                  onTap: () => onHoleTap(hole),
                  child: Container(
                    height: 44,
                    margin: const EdgeInsets.symmetric(vertical: 1),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$hole',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          GestureDetector(
            onTap: onTrophy,
            child: Container(
              height: 44,
              width: 44,
              margin: const EdgeInsets.only(top: 2, bottom: 4),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.emoji_events, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

void _showWinnersSheet(BuildContext context, LiveResults live) {
  final skins = live.skins;
  final winners = skins.where((s) => s.value > 0).toList();
  final totalPot = winners.fold<double>(0, (sum, s) => sum + s.value);
  showModalBottomSheet(
    context: context,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            winners.isEmpty ? 'No skins won yet' : '${winners.length} skin${winners.length == 1 ? '' : 's'} won',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (totalPot > 0)
            Text('Total payout: \$${totalPot.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 12),
          for (final s in winners)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(width: 50, child: Text('Hole ${s.hole}', style: const TextStyle(fontWeight: FontWeight.w600))),
                  Expanded(child: Text('${s.winner}${s.wonWithPar ? ' (par)' : ''}${s.deductPercent > 0 ? ' (${s.deductPercent}% deducted)' : ''}')),
                  Text('\$${s.value.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B5A17))),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}
