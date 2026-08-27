import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/player_directory.dart';
import '../../domain/entities/contest_config.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/kp_live.dart';
import '../../domain/live_results.dart';
import '../../../profile/domain/entities/user_profile.dart';

class KpLivePage extends StatefulWidget {
  const KpLivePage({super.key, required this.tournament});
  final Tournament tournament;
  @override
  State<KpLivePage> createState() => _KpLivePageState();
}

class _KpLivePageState extends State<KpLivePage> {
  LiveResults? _live;
  int? _hole;
  ContestCategory _category = ContestCategory.open;

  ContestConfig get _config => widget.tournament.contests ?? ContestConfig(holePars: ContestConfig.defaultPars());

  @override
  void initState() {
    super.initState();
    _live = GetIt.instance<LiveResultsRegistry>().existing(widget.tournament.id);
    _live?.addListener(_onLive);
    final kp = _config.kpHoles;
    if (kp.isNotEmpty) _hole = kp.first;
    if (_config.useCategories) _category = ContestCategory.men;
  }

  @override
  void dispose() { _live?.removeListener(_onLive); super.dispose(); }
  void _onLive() { if (mounted) setState(() {}); }

  List<ContestCategory> get _categories => _config.useCategories
      ? const [ContestCategory.men, ContestCategory.seniorMen, ContestCategory.women, ContestCategory.seniorWomen]
      : const [ContestCategory.open];

  ContestCategory _categoryFor(String player) {
    final entry = GetIt.instance<PlayerDirectory>().lookup(player);
    final female = entry.gender == Gender.female;
    if (entry.senior) return female ? ContestCategory.seniorWomen : ContestCategory.seniorMen;
    return female ? ContestCategory.women : ContestCategory.men;
  }

  Future<void> _measure(LiveResults live, int hole) async {
    final players = live.players;
    String? measuredBy;
    String? player;
    double? distance;
    var step = 0;
    final distCtrl = TextEditingController();

    final done = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setD) {
          Widget body;
          if (step == 0) {
            body = Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Who is measuring? The measurer records a teammate\'s ball, never their own.'),
              const SizedBox(height: 10),
              DropdownButton<String>(value: measuredBy, hint: const Text('Measurer'), isExpanded: true,
                items: [for (final p in players) DropdownMenuItem(value: p, child: Text(p))],
                onChanged: (v) => setD(() => measuredBy = v)),
            ]);
          } else if (step == 1) {
            body = Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Anchor 1 of 2'),
              const SizedBox(height: 6),
              const Text('Remove the flag. Center the dot inside the cup and take the picture. The ruler activates from this point.'),
              const SizedBox(height: 6),
              Text('Ball must be on the green to qualify.', style: AppTextStyles.caption(AppColors.goldDark)),
            ]);
          } else if (step == 2) {
            body = Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Anchor 2 of 2'),
              const SizedBox(height: 6),
              const Text('Walk to the ball keeping the ruler on screen. The ball must sit inside the circle for the picture and the distance to record.'),
              const SizedBox(height: 10),
              TextField(controller: distCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Measured distance (feet)', helperText: 'Simulated ruler until the AR session is wired')),
            ]);
          } else {
            final selectable = [for (final p in players) if (p != measuredBy) p];
            body = Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Whose ball is this? The measurer cannot pick themselves.'),
              const SizedBox(height: 10),
              DropdownButton<String>(value: player, hint: const Text('Player'), isExpanded: true,
                items: [for (final p in selectable) DropdownMenuItem(value: p, child: Text(p))],
                onChanged: (v) => setD(() => player = v)),
            ]);
          }
          final canNext = switch (step) { 0 => measuredBy != null, 1 => true, 2 => double.tryParse(distCtrl.text.trim()) != null, _ => player != null };
          return AlertDialog(
            title: Text('KP Live, hole $hole'),
            content: body,
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: canNext ? () {
                  if (step < 3) { if (step == 2) distance = double.tryParse(distCtrl.text.trim()); setD(() => step += 1); }
                  else { Navigator.of(context).pop(true); }
                } : null,
                child: Text(step == 1 ? 'Take picture' : step == 2 ? 'Take picture and record' : step < 3 ? 'Next' : 'Submit')),
            ],
          );
        },
      ),
    );
    if (done != true || measuredBy == null || player == null || distance == null) return;
    final cat = _config.useCategories ? _categoryFor(player!) : ContestCategory.open;
    final result = live.submitKp(hole: hole, player: player!, measuredBy: measuredBy!, category: cat, distanceFeet: double.parse(distance!.toStringAsFixed(1)));
    if (!mounted) return;
    final msg = switch (result) {
      KpSubmitResult.accepted => 'Recorded. $player leads hole $hole.',
      KpSubmitResult.notCloser => 'Not closer than the leader. First recorded stands, it must be beaten, not matched.',
      KpSubmitResult.measurerIsPlayer => 'The measurer cannot record their own ball.',
      KpSubmitResult.holeNotKp => 'That hole is not a KP hole in this event.',
      KpSubmitResult.resultsFinal => 'Results are final.',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final live = _live;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    if (live == null) return Scaffold(appBar: AppBar(title: const Text('KP Live')), body: const Center(child: Text('KP Live opens once score entry starts.')));
    final kpHoles = _config.kpHoles;
    final hole = _hole;
    return Scaffold(
      appBar: AppBar(title: const Text('KP Live')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(widget.tournament.name, style: AppTextStyles.heading3(primaryText)),
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final h in kpHoles) ChoiceChip(label: Text(live.kpPinnedHoles.contains(h) ? 'Hole $h' : 'Hole $h (not pinned)'), selected: hole == h, onSelected: (_) => setState(() => _hole = h)),
        ]),
        if (hole != null && !live.kpPinnedHoles.contains(hole)) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(icon: const Icon(Icons.push_pin_outlined), label: Text('We are at hole $hole, pin it'),
            onPressed: live.isFinal ? null : () => live.pinKpHole(hole)),
          Text('The first group to arrive pins the hole so it pops up for every group behind them.', style: AppTextStyles.caption(secondaryText)),
        ],
        if (_config.useCategories) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 6, children: [for (final c in _categories) ChoiceChip(label: Text(c.label), selected: _category == c, onSelected: (_) => setState(() => _category = c))]),
        ],
        const SizedBox(height: 14),
        if (hole != null) ...[
          for (final (i, e) in live.kpBoard(hole, _category).indexed)
            Container(margin: const EdgeInsets.symmetric(vertical: 3), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: isDark ? AppColors.darkSurface : AppColors.white, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: i == 0 ? AppColors.gold : AppColors.greyLight)),
              child: Row(children: [
                if (i == 0) const Icon(Icons.photo_camera, size: 18, color: AppColors.goldDark),
                if (i == 0) const SizedBox(width: 8),
                Expanded(child: Text('${e.player}  (measured by ${e.measuredBy})', style: i == 0 ? AppTextStyles.bodyBold(primaryText) : AppTextStyles.body(secondaryText))),
                Text('${e.distanceFeet.toStringAsFixed(1)} ft', style: i == 0 ? AppTextStyles.bodyBold(AppColors.goldDark) : AppTextStyles.body(secondaryText)),
              ])),
          if (live.kpBoard(hole, _category).isEmpty) Text('No measurements yet on hole $hole.', style: AppTextStyles.body(secondaryText)),
          const SizedBox(height: 14),
          ElevatedButton.icon(icon: const Icon(Icons.straighten), label: const Text('Measure'),
            onPressed: live.isFinal || !live.kpPinnedHoles.contains(hole) ? null : () => _measure(live, hole)),
          if (!live.kpPinnedHoles.contains(hole)) Text('Pin the hole before measuring.', style: AppTextStyles.caption(secondaryText)),
        ],
      ]),
    );
  }
}
