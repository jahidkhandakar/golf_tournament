import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/indoor.dart';

/// Game-day sim board: one column per simulator (bay), the creator taps a
/// player then taps a bay to place or reassign them. There is no self-pairing
/// — this is the creator's tool. The full monitor-sized drag-and-drop builder
/// lives on the desktop dashboard (spec §14); the phone keeps the reduced
/// last-minute version: see the bays and swap players around.
class SimBoardPage extends StatefulWidget {
  const SimBoardPage({super.key, required this.sessionId});

  final String sessionId;

  @override
  State<SimBoardPage> createState() => _SimBoardPageState();
}

class _SimBoardPageState extends State<SimBoardPage> {
  final IndoorState _state = GetIt.instance<IndoorState>();
  String? _selected;

  @override
  void initState() {
    super.initState();
    _state.addListener(_onChange);
  }

  @override
  void dispose() {
    _state.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  SimSession get _session => _state.sessions.firstWhere((s) => s.id == widget.sessionId);

  void _tapPlayer(String player) => setState(() => _selected = _selected == player ? null : player);

  void _tapBay(int bayIndex) {
    final player = _selected;
    if (player == null) return;
    if (_session.isBayFull(bayIndex) && !_session.playersInBay(bayIndex).contains(player)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That bay is full.')),
      );
      return;
    }
    _state.assignToBay(_session, player, bayIndex);
    setState(() => _selected = null);
  }

  Future<void> _addPlayer() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add player'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Player name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(ctrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) _state.addToRoster(_session, name);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final session = _session;

    return Scaffold(
      appBar: AppBar(
        title: Text(session.title),
        actions: [
          IconButton(tooltip: 'Add player', icon: const Icon(Icons.person_add_alt), onPressed: _addPlayer),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              '${session.bayCount} sims · up to ${session.perBayCapacity} per bay · '
              'capacity ${session.booking.capacity}'
              '${session.isSocialRound ? ' · Sim Social Round' : ''}',
              style: AppTextStyles.caption(secondaryText),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _selected == null
                  ? 'Tap a player, then tap a bay to place or move them.'
                  : 'Moving "$_selected" — tap a bay, or tap "Unassigned" to remove.',
              style: AppTextStyles.caption(_selected == null ? secondaryText : AppColors.goldDark),
            ),
          ),
          const SizedBox(height: 8),
          // The bays: one column per simulator, scrolling horizontally.
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < session.bayCount; i++)
                    _BayColumn(
                      index: i,
                      players: session.playersInBay(i),
                      capacity: session.perBayCapacity,
                      selected: _selected,
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                      onTapBay: () => _tapBay(i),
                      onTapPlayer: _tapPlayer,
                    ),
                ],
              ),
            ),
          ),
          _UnassignedTray(
            players: session.unassigned,
            selected: _selected,
            primaryText: primaryText,
            secondaryText: secondaryText,
            onTapPlayer: _tapPlayer,
            onTapTray: () => _tapBay(-1),
          ),
        ],
      ),
    );
  }
}

class _BayColumn extends StatelessWidget {
  const _BayColumn({
    required this.index,
    required this.players,
    required this.capacity,
    required this.selected,
    required this.primaryText,
    required this.secondaryText,
    required this.onTapBay,
    required this.onTapPlayer,
  });

  final int index;
  final List<String> players;
  final int capacity;
  final String? selected;
  final Color primaryText;
  final Color secondaryText;
  final VoidCallback onTapBay;
  final void Function(String) onTapPlayer;

  @override
  Widget build(BuildContext context) {
    final full = players.length >= capacity;
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12, bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTapBay,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(Icons.sports_golf, size: 16, color: AppColors.goldDark),
                  const SizedBox(width: 6),
                  Expanded(child: Text('Bay ${index + 1}', style: AppTextStyles.bodyBold(primaryText))),
                  Text('${players.length}/$capacity',
                      style: AppTextStyles.caption(full ? AppColors.error : secondaryText)),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                for (final p in players)
                  _PlayerChip(name: p, selected: p == selected, onTap: () => onTapPlayer(p)),
                if (players.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text('Empty', style: AppTextStyles.caption(secondaryText)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnassignedTray extends StatelessWidget {
  const _UnassignedTray({
    required this.players,
    required this.selected,
    required this.primaryText,
    required this.secondaryText,
    required this.onTapPlayer,
    required this.onTapTray,
  });

  final List<String> players;
  final String? selected;
  final Color primaryText;
  final Color secondaryText;
  final void Function(String) onTapPlayer;
  final VoidCallback onTapTray;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: InkWell(
        onTap: onTapTray,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Unassigned (${players.length})', style: AppTextStyles.bodyBold(primaryText)),
              const SizedBox(height: 8),
              if (players.isEmpty)
                Text('Everyone has a bay.', style: AppTextStyles.caption(secondaryText))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in players)
                      _PlayerChip(name: p, selected: p == selected, onTap: () => onTapPlayer(p)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerChip extends StatelessWidget {
  const _PlayerChip({required this.name, required this.selected, required this.onTap});

  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.gold : AppColors.gold.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? AppColors.goldDark : Colors.transparent),
          ),
          child: Text(
            name,
            style: AppTextStyles.caption(selected ? AppColors.white : AppColors.goldDark),
          ),
        ),
      ),
    );
  }
}
