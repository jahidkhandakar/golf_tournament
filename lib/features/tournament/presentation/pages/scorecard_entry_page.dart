import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/permission/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/player_score.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/repositories/registration_repository.dart';
import '../../domain/repositories/scorecard_repository.dart';
import '../../domain/skins.dart';

const int _holeCount = 9; // front nine, for a bounded by-hole entry demo

/// Club Creator / sub-admin scorecard entry (§6). Scores can be gross-only or
/// by-hole; submitting runs the skins calculator (for skins formats) and, in
/// production, the Handicap / Top 50 / Club Leaderboard engines.
class ScorecardEntryPage extends StatefulWidget {
  const ScorecardEntryPage({super.key, required this.tournament});

  final Tournament tournament;

  @override
  State<ScorecardEntryPage> createState() => _ScorecardEntryPageState();
}

class _ScorecardEntryPageState extends State<ScorecardEntryPage> {
  final ScorecardRepository _repo = GetIt.instance<ScorecardRepository>();
  final RegistrationRepository _registration = GetIt.instance<RegistrationRepository>();
  final PermissionService _permission = GetIt.instance<PermissionService>();

  final Map<String, TextEditingController> _grossControllers = {};

  List<PlayerScore> _scores = [];
  bool _byHole = false;
  bool _submitted = false;
  bool _loading = true;
  bool _busy = false;

  bool get _canEnter => _permission.canEnterScorecard(widget.tournament.clubName);
  bool get _allScored => _scores.isNotEmpty && _scores.every((s) => s.gross != null);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _grossControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    if (!_canEnter) {
      setState(() => _loading = false);
      return;
    }
    final players = await _registration.registeredPlayers(widget.tournament.id);
    final card = await _repo.load(widget.tournament.id, players);
    if (!mounted) return;
    setState(() {
      _scores = List.of(card.scores);
      _submitted = card.submitted;
      for (final s in _scores) {
        _grossControllers[s.playerName] = TextEditingController(text: s.gross?.toString() ?? '');
      }
      _loading = false;
    });
  }

  void _setGross(String player, String text) {
    final gross = int.tryParse(text.trim());
    final i = _scores.indexWhere((s) => s.playerName == player);
    if (i < 0) return;
    setState(() => _scores[i] = PlayerScore(playerName: player, gross: gross));
  }

  Future<void> _editHoles(String player) async {
    final i = _scores.indexWhere((s) => s.playerName == player);
    if (i < 0) return;
    final holes = await showDialog<List<int>>(
      context: context,
      builder: (context) => _HolesDialog(playerName: player, initial: _scores[i].holes),
    );
    if (holes == null) return;
    final gross = holes.fold<int>(0, (a, b) => a + b);
    setState(() {
      _scores[i] = PlayerScore(playerName: player, gross: gross, holes: holes);
      _grossControllers[player]?.text = gross.toString();
    });
  }

  Future<void> _submit() async {
    if (!_allScored) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a score for every player first.')),
      );
      return;
    }
    setState(() => _busy = true);
    final card = await _repo.submit(widget.tournament.id, _scores);
    if (!mounted) return;
    setState(() {
      _submitted = card.submitted;
      _busy = false;
    });
    await _showResults();
  }

  Future<void> _showResults() {
    final isSkins = widget.tournament.format.toLowerCase() == 'skins';
    String? skinsSummary;
    if (isSkins) {
      final byHole = Skins.holeSkins(_scores);
      if (byHole.isNotEmpty) {
        final tally = <String, int>{};
        for (final winner in byHole.values) {
          tally[winner] = (tally[winner] ?? 0) + 1;
        }
        skinsSummary = tally.entries.map((e) => '${e.key} — ${e.value} skin${e.value == 1 ? '' : 's'}').join('\n');
      } else {
        final winner = Skins.grossSkin(_scores);
        skinsSummary = winner == null ? 'No outright skin (tie).' : '$winner wins the skin (low gross).';
      }
    }

    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Results submitted'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (skinsSummary != null) ...[
              Text('Skins', style: AppTextStyles.bodyBold(AppColors.goldDark)),
              const SizedBox(height: 4),
              Text(skinsSummary),
              const SizedBox(height: 12),
            ],
            const Text('The Handicap, Top 50, and Club Leaderboard engines have been updated.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Done')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scorecard'),
        actions: [
          if (_submitted)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(20)),
                  child: Text('Submitted', style: AppTextStyles.caption(AppColors.success)),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_canEnter
              ? Center(child: Text('Admins only', style: AppTextStyles.body(secondaryText)))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Row(
                        children: [
                          Text('Entry', style: AppTextStyles.caption(secondaryText)),
                          const SizedBox(width: 10),
                          ChoiceChip(
                            label: const Text('Gross'),
                            selected: !_byHole,
                            onSelected: (_) => setState(() => _byHole = false),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('By hole'),
                            selected: _byHole,
                            onSelected: (_) => setState(() => _byHole = true),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _scores.length,
                        itemBuilder: (context, index) => _row(_scores[index], primaryText, secondaryText),
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: (_loading || !_canEnter)
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: ElevatedButton(
                  onPressed: _busy ? null : _submit,
                  child: Text(_submitted ? 'Re-submit scores' : 'Submit scores'),
                ),
              ),
            ),
    );
  }

  Widget _row(PlayerScore score, Color primaryText, Color secondaryText) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 12, 6),
        child: Row(
          children: [
            Expanded(child: Text(score.playerName, style: AppTextStyles.bodyBold(primaryText))),
            if (_byHole)
              TextButton.icon(
                onPressed: () => _editHoles(score.playerName),
                icon: const Icon(Icons.grid_on, size: 16),
                label: Text(score.gross != null ? '${score.gross}' : 'Enter holes'),
              )
            else
              SizedBox(
                width: 72,
                child: TextField(
                  controller: _grossControllers[score.playerName],
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(hintText: 'Gross', isDense: true),
                  onChanged: (v) => _setGross(score.playerName, v),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Dialog to enter a player's front-nine hole scores; returns the 9 values.
class _HolesDialog extends StatefulWidget {
  const _HolesDialog({required this.playerName, this.initial});

  final String playerName;
  final List<int>? initial;

  @override
  State<_HolesDialog> createState() => _HolesDialogState();
}

class _HolesDialogState extends State<_HolesDialog> {
  late final List<TextEditingController> _controllers = List.generate(
    _holeCount,
    (i) => TextEditingController(
      text: (widget.initial != null && i < widget.initial!.length ? widget.initial![i] : 4).toString(),
    ),
  );

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.playerName} · holes 1–$_holeCount'),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < _holeCount; i++)
            SizedBox(
              width: 52,
              child: TextField(
                controller: _controllers[i],
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                decoration: InputDecoration(labelText: '${i + 1}', isDense: true),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            final holes = [for (final c in _controllers) int.tryParse(c.text.trim()) ?? 0];
            Navigator.of(context).pop(holes);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
