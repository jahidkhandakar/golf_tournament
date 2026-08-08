import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/indoor.dart';

/// Indoor golf home: standalone leagues and Sim Social Rounds, fully
/// separated from outdoor. Sim board replaces the tee sheet: columns per
/// simulator, creator drags players into bays and makes the teams. Displayed
/// in the app only; no email to any course.
class IndoorPage extends StatefulWidget {
  const IndoorPage({super.key});
  @override
  State<IndoorPage> createState() => _IndoorPageState();
}

class _IndoorPageState extends State<IndoorPage> {
  final IndoorState _state = GetIt.instance<IndoorState>();

  @override
  void initState() { super.initState(); _state.addListener(_onChange); }
  @override
  void dispose() { _state.removeListener(_onChange); super.dispose(); }
  void _onChange() { if (mounted) setState(() {}); }

  Future<void> _createLeague() async {
    final nameCtrl = TextEditingController();
    final facilityCtrl = TextEditingController();
    final feeCtrl = TextEditingController();
    var sims = 2, hours = 4; var extra = false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setD) => AlertDialog(
        title: const Text('Create Indoor League'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'League name')),
          TextField(controller: facilityCtrl, decoration: const InputDecoration(labelText: 'Facility name')),
          TextField(controller: feeCtrl, decoration: const InputDecoration(labelText: 'Entry fee note (display only)', helperText: 'The app never collects money')),
          const SizedBox(height: 10),
          Row(children: [
            const Expanded(child: Text('Simulators booked')),
            IconButton(onPressed: sims > 1 ? () => setD(() => sims--) : null, icon: const Icon(Icons.remove)),
            Text('$sims'),
            IconButton(onPressed: () => setD(() => sims++), icon: const Icon(Icons.add)),
          ]),
          Row(children: [
            const Expanded(child: Text('Hours per sim')),
            IconButton(onPressed: hours > 1 ? () => setD(() => hours--) : null, icon: const Icon(Icons.remove)),
            Text('$hours'),
            IconButton(onPressed: () => setD(() => hours++), icon: const Icon(Icons.add)),
          ]),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Allow one extra per sim'),
            subtitle: const Text('Rarely finishable'), value: extra, onChanged: (v) => setD(() => extra = v)),
          Text('Capacity: ${SimBooking(sims: sims, hoursPerSim: hours, allowExtraPerSim: extra).capacity} players',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Create')),
        ],
      )),
    );
    if (ok != true || nameCtrl.text.trim().isEmpty) return;
    _state.createLeague(
      name: nameCtrl.text.trim(),
      facilityName: facilityCtrl.text.trim(),
      booking: SimBooking(sims: sims, hoursPerSim: hours, allowExtraPerSim: extra),
      entryFeeNote: feeCtrl.text.trim(),
    );
  }

  /// A one-time Sim Social Round: create the session and open its sim board so
  /// the creator can place the invited players into bays. Seeded with a small
  /// roster to arrange (real rosters arrive once the backend is wired).
  Future<void> _createSocialRound() async {
    final session = _state.createSession(
      title: 'Sim Social Round',
      booking: const SimBooking(sims: 2, hoursPerSim: 4),
      isSocialRound: true,
      roster: const ['Ana Ruiz', 'Ben Cole', 'Cam Diaz', 'Drew Kim', 'Eli Fox', 'Fay Ng'],
    );
    if (!mounted) return;
    context.push(AppRoutes.simBoard, extra: session.id);
  }

  /// Open the sim board for a league, creating a session on first use.
  void _openLeagueBoard(IndoorLeague league) {
    final existing = _state.sessions.where((s) => s.title == league.name);
    final session = existing.isNotEmpty
        ? existing.first
        : _state.createSession(
            title: league.name,
            booking: league.booking,
            roster: [for (final m in league.members) m.player],
          );
    context.push(AppRoutes.simBoard, extra: session.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    return Scaffold(
      appBar: AppBar(title: const Text('Indoor Golf')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('Simulator leagues and Sim Social Rounds. Indoor golf is fully separate from outdoor: its own Indoor Handicap, its own flights, nothing crosses over.',
          style: AppTextStyles.caption(secondaryText)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.emoji_events_outlined),
            label: const Text('Create League'), onPressed: _createLeague)),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.sports_golf),
            label: const Text('Sim Social Round'),
            onPressed: _createSocialRound)),
        ]),
        const SizedBox(height: 16),
        for (final l in _state.leagues)
          _LeagueCard(
            league: l,
            primaryText: primaryText,
            secondaryText: secondaryText,
            onOpenBoard: () => _openLeagueBoard(l),
          ),
        if (_state.leagues.isEmpty)
          Padding(padding: const EdgeInsets.only(top: 24),
            child: Text('No leagues yet. Create the first one above.', style: AppTextStyles.body(secondaryText))),
      ]),
    );
  }
}

class _LeagueCard extends StatelessWidget {
  const _LeagueCard({
    required this.league,
    required this.primaryText,
    required this.secondaryText,
    required this.onOpenBoard,
  });
  final IndoorLeague league;
  final Color primaryText;
  final Color secondaryText;
  final VoidCallback onOpenBoard;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(league.name, style: AppTextStyles.heading3(primaryText))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (league.entryOpen ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12)),
            child: Text(league.entryOpen ? 'Entry open' : 'Entry closed',
              style: AppTextStyles.caption(league.entryOpen ? AppColors.success : AppColors.error)),
          ),
        ]),
        const SizedBox(height: 4),
        Text('${league.facilityName} · ${league.booking.sims} sims · ${league.totalRounds} Rounds · capacity ${league.booking.capacity}',
          style: AppTextStyles.caption(secondaryText)),
        if (league.entryFeeNote.isNotEmpty)
          Text('Entry: ${league.entryFeeNote}', style: AppTextStyles.caption(secondaryText)),
        const SizedBox(height: 6),
        Text('Weeks run Monday to midnight Sunday. Bank up to 2 extra Rounds ahead; unlimited makeups in a week when behind. Entry closes 3 weeks in. Skins need a witnessed round: both players checked in and playing, verified at check-in, one silent random moment, and session close against the pinned sim location.',
          style: AppTextStyles.caption(secondaryText)),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.grid_view, size: 18),
            label: const Text('Sim board'),
            onPressed: onOpenBoard,
          ),
        ),
      ]),
    );
  }
}
