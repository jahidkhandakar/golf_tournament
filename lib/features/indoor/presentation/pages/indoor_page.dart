import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/permission/feature.dart';
import '../../../../core/permission/permission_service.dart';
import '../../domain/indoor.dart';
import 'league_home_page.dart';

/// Indoor home and listing page: My Leagues, Casual Rounds (Sim Social
/// Rounds), and the two create entry points. Indoor stays fully separate from
/// outdoor.
class IndoorPage extends StatefulWidget {
  const IndoorPage({super.key});
  @override
  State<IndoorPage> createState() => _IndoorPageState();
}

class _IndoorPageState extends State<IndoorPage> {
  final IndoorState _state = GetIt.instance<IndoorState>();
  @override
  void initState() { super.initState(); _state.addListener(_c); }
  @override
  void dispose() { _state.removeListener(_c); super.dispose(); }
  void _c() { if (mounted) setState(() {}); }

  Future<void> _createLeague() async {
    final name = TextEditingController(); final fac = TextEditingController();
    final fee = TextEditingController();
    var weeks = 10; var skins = true; var photos = false; var mid = false; var amounts = false;
    var pinned = false; var isPublic = false;
    final ok = await showDialog<bool>(context: context, builder: (context) =>
      StatefulBuilder(builder: (context, setD) => AlertDialog(
        title: const Text('Create Season League'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'League name')),
          TextField(controller: fac, decoration: const InputDecoration(labelText: 'Facility name')),
          Row(children: [
            Expanded(child: Text(pinned ? 'Sim location pinned' : 'Pin sim location (required)')),
            IconButton(icon: Icon(pinned ? Icons.check_circle : Icons.push_pin_outlined,
              color: pinned ? Colors.green : null), onPressed: () => setD(() => pinned = true)),
          ]),
          Row(children: [
            const Expanded(child: Text('Season length (weeks)')),
            IconButton(onPressed: weeks > 3 ? () => setD(() => weeks--) : null, icon: const Icon(Icons.remove)),
            Text('$weeks'),
            IconButton(onPressed: weeks < 18 ? () => setD(() => weeks++) : null, icon: const Icon(Icons.add)),
          ]),
          TextField(controller: fee, decoration: const InputDecoration(labelText: 'Entry fee note (display only)',
            helperText: 'The app never collects money')),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Public league'),
            subtitle: const Text('Facility managers only. Listed to the 60-mile zone after GGW verification. Private is pay-and-go, invite-only, worldwide.'),
            value: isPublic, onChanged: (v) => setD(() => isPublic = v)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Skins'),
            subtitle: const Text('Witness verification required when on'), value: skins, onChanged: (v) => setD(() => skins = v)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Allow screen photos for scoring'),
            subtitle: const Text('Only the verifier may take and send the photo'), value: photos, onChanged: (v) => setD(() => photos = v)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Mid-season prizes'), value: mid, onChanged: (v) => setD(() => mid = v)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Show amounts'),
            subtitle: const Text('Purged 24 hours after results'), value: amounts, onChanged: (v) => setD(() => amounts = v)),
          const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(top: 6),
            child: Text('Sims and hours are entered per booking at the front desk, not here. Next: enter each week\'s course and rating.',
              style: TextStyle(fontSize: 12)))),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: pinned && name.text.trim().isNotEmpty || true ? () => Navigator.pop(context, true) : null,
            child: const Text('Next: weekly courses')),
        ])));
    if (ok != true || name.text.trim().isEmpty || !pinned) {
      if (ok == true && !pinned && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pin the sim location to create the league.')));
      }
      return;
    }
    final league = IndoorLeague(id: 'L${_state.leagues.length + 1}', name: name.text.trim(),
      facilityName: fac.text.trim(), seasonWeeks: weeks, entryFeeNote: fee.text.trim(),
      skinsOn: skins, allowScreenPhotos: photos, midSeasonPrizes: mid, showAmounts: amounts,
      entryCutoffWeek: (weeks / 2).ceil(), isPublic: isPublic);
    if (!mounted) return;
    await _editCourses(league);
    _state.addLeague(league);
  }

  Future<void> _editCourses(IndoorLeague league) async {
    await showDialog<void>(context: context, builder: (context) => AlertDialog(
      title: const Text('Weekly courses (week 1 required, rest anytime)'),
      content: SizedBox(width: double.maxFinite, child: ListView.builder(shrinkWrap: true,
        itemCount: league.courses.length,
        itemBuilder: (context, i) {
          final c = league.courses[i];
          return Row(children: [
            SizedBox(width: 34, child: Text('W${c.week}')),
            Expanded(child: TextFormField(initialValue: c.course,
              decoration: const InputDecoration(hintText: 'Course', isDense: true),
              onChanged: (v) { c.course = v; final d = CourseDirectory.courses[v.trim()]; if (d != null) { c.rating = d.$1; c.slope = d.$2; } })),
            SizedBox(width: 56, child: TextFormField(initialValue: c.rating.toStringAsFixed(1),
              decoration: const InputDecoration(hintText: 'Rtg', isDense: true),
              keyboardType: TextInputType.number,
              onChanged: (v) => c.rating = double.tryParse(v) ?? c.rating)),
            SizedBox(width: 46, child: TextFormField(initialValue: '${c.slope}',
              decoration: const InputDecoration(hintText: 'Slp', isDense: true),
              keyboardType: TextInputType.number,
              onChanged: (v) => c.slope = int.tryParse(v) ?? c.slope)),
          ]);
        })),
      actions: [ElevatedButton(onPressed: () { for (final c in league.courses) { CourseDirectory.save(c.course, c.rating, c.slope); } Navigator.pop(context); }, child: const Text('Create League'))],
    ));
  }

  Future<void> _createCasual() async {
    final name = TextEditingController(); final fac = TextEditingController();
    var skins = false; var sims = 2; var hours = 4; var extra = false;
    // Declared for the "Public league" switch below. NOTE: CasualRound has no
    // public/approval concept, so this currently has no effect on a Sim Social.
    var isPublic = false;
    final ok = await showDialog<bool>(context: context, builder: (context) =>
      StatefulBuilder(builder: (context, setD) => AlertDialog(
        title: const Text('Sim Social Round'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: fac, decoration: const InputDecoration(labelText: 'Facility name')),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Public league'),
            subtitle: const Text('Facility managers only. Listed to the 60-mile zone after GGW verification. Private is pay-and-go, invite-only, worldwide.'),
            value: isPublic, onChanged: (v) => setD(() => isPublic = v)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Skins'),
            subtitle: const Text('Off means casual'), value: skins, onChanged: (v) => setD(() => skins = v)),
          Row(children: [const Expanded(child: Text('Simulators')),
            IconButton(onPressed: sims > 1 ? () => setD(() => sims--) : null, icon: const Icon(Icons.remove)),
            Text('$sims'), IconButton(onPressed: () => setD(() => sims++), icon: const Icon(Icons.add))]),
          Row(children: [const Expanded(child: Text('Hours per sim')),
            IconButton(onPressed: hours > 1 ? () => setD(() => hours--) : null, icon: const Icon(Icons.remove)),
            Text('$hours'), IconButton(onPressed: () => setD(() => hours++), icon: const Icon(Icons.add))]),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Allow one extra per sim'),
            value: extra, onChanged: (v) => setD(() => extra = v)),
          Text('Capacity: ${sims * hours + (extra ? sims : 0)}'),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create'))])));
    if (ok != true || name.text.trim().isEmpty) return;
    _state.addCasual(CasualRound(id: 'C${_state.casuals.length + 1}', name: name.text.trim(),
      facilityName: fac.text.trim(), withSkins: skins, sims: sims, hours: hours, extraPerSim: extra));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Indoor Golf')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Builder(builder: (context) {
          final canCreate = GetIt.instance<PermissionService>().can(Feature.createIndoorLeague);
          return Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => setState(() {}), child: const Text('Home'))),
            if (canCreate) ...[
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(onPressed: _createLeague, child: const Text('Create League'))),
            ],
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(onPressed: _createCasual, child: const Text('Sim Social'))),
          ]);
        }),
        const SizedBox(height: 14),
        Text('Leagues: public in your zone and your invited private', style: Theme.of(context).textTheme.titleMedium),
        for (final l in _state.leagues) Card(child: ListTile(
          title: Text(l.name),
          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${l.facilityName}  ·  ${l.seasonWeeks} weeks  ·  week ${l.currentWeek}: ${l.courses[l.currentWeek - 1].course.isEmpty ? 'course TBD' : l.courses[l.currentWeek - 1].course}'),
            if (l.isPublic && !l.publicApproved)
              const Text('Public listing pending GGW verification', style: TextStyle(fontSize: 12)),
            if (l.missedFor('You').isNotEmpty)
              Text('Your missed rounds: ${l.missedFor('You').map((c) => 'Week ${c.week}  ${c.course}').join(', ')}',
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          ]),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LeagueHomePage(league: l))))),
        if (_state.leagues.isEmpty) const Text('No leagues yet.'),
        const SizedBox(height: 14),
        Text('Sim Social Rounds', style: Theme.of(context).textTheme.titleMedium),
        for (final c in _state.casuals.where((c) => !c.expired)) Card(child: ListTile(
          title: Text(c.name),
          subtitle: Text('${c.facilityName}  ·  ${c.withSkins ? 'Skins' : 'Casual'}  ·  ${c.sims} sims  ·  capacity ${c.capacity}${c.joinable ? '' : '  ·  started, joining closed'}'))),
        if (_state.casuals.isEmpty) const Text('No Sim Social Rounds yet.'),
      ]));
  }
}
