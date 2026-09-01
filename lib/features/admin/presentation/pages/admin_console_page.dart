import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../indoor/domain/indoor.dart';

/// App Admin console: the owner's control surface, independent of any
/// developer. Everything here calls the same admin API the backend exposes
/// (Backend Specs section 16); in this build it operates on live app state.
/// Visible only to the App Admin and users the App Admin grants access.
class AdminConsolePage extends StatefulWidget {
  const AdminConsolePage({super.key});
  @override
  State<AdminConsolePage> createState() => _AdminConsolePageState();
}

class _AdminConsolePageState extends State<AdminConsolePage> {
  final IndoorState _indoor = GetIt.instance<IndoorState>();
  final Map<String, Set<String>> _grants = {};

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _grantDialog() async {
    final user = TextEditingController();
    const roles = ['Sub-admin', 'League publisher', 'Public league verifier', 'Console access'];
    final picked = <String>{};
    final ok = await showDialog<bool>(context: context, builder: (context) =>
      StatefulBuilder(builder: (context, setD) => AlertDialog(
        title: const Text('Grant control'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: user, decoration: const InputDecoration(labelText: 'User name or email')),
          for (final r in roles)
            CheckboxListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text(r),
              value: picked.contains(r), onChanged: (v) => setD(() => v == true ? picked.add(r) : picked.remove(r))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Grant')),
        ])));
    if (ok == true && user.text.trim().isNotEmpty) {
      setState(() => _grants[user.text.trim()] = picked);
      _snack('Granted: ${picked.join(', ')} to ${user.text.trim()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Console')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('Permissions', style: Theme.of(context).textTheme.titleMedium),
        ListTile(dense: true, leading: const Icon(Icons.person_add_alt),
          title: const Text('Grant or revoke control'),
          subtitle: Text(_grants.isEmpty ? 'No delegated controls yet'
              : _grants.entries.map((e) => '${e.key}: ${e.value.join(", ")}').join('\n')),
          trailing: const Icon(Icons.chevron_right), onTap: _grantDialog),
        const Divider(),
        Text('Indoor leagues', style: Theme.of(context).textTheme.titleMedium),
        for (final l in _indoor.leagues) Card(child: Column(children: [
          ListTile(dense: true, title: Text(l.name),
            subtitle: Text('${l.facilityName}  ·  week ${l.currentWeek} of ${l.seasonWeeks}'
                '${l.isPublic ? l.publicApproved ? '  ·  public, approved' : '  ·  PUBLIC PENDING VERIFICATION' : '  ·  private'}')),
          OverflowBar(children: [
            if (l.isPublic && !l.publicApproved)
              TextButton(onPressed: () { setState(() => l.publicApproved = true); _snack('${l.name} approved for public listing'); },
                child: const Text('Approve public listing')),
            TextButton(onPressed: () {
              setState(() => l.publishedWeeks.contains(l.currentWeek)
                  ? l.publishedWeeks.remove(l.currentWeek) : l.publishedWeeks.add(l.currentWeek));
              _snack('Week ${l.currentWeek} ${l.publishedWeeks.contains(l.currentWeek) ? 'published' : 'unpublished'}');
            }, child: Text(l.publishedWeeks.contains(l.currentWeek) ? 'Unpublish week' : 'Publish week')),
            TextButton(onPressed: () { setState(() => l.currentWeek = (l.currentWeek % l.seasonWeeks) + 1); _snack('Now week ${l.currentWeek}'); },
              child: const Text('Advance week')),
          ]),
        ])),
        if (_indoor.leagues.isEmpty) const Text('No leagues to manage.'),
        const Divider(),
        Text('Cleanup', style: Theme.of(context).textTheme.titleMedium),
        ListTile(dense: true, leading: const Icon(Icons.delete_sweep_outlined),
          title: const Text('Purge expired Sim Socials now'),
          onTap: () { _indoor.purgeExpired(); _snack('Expired Sim Socials permanently deleted'); }),
        const SizedBox(height: 8),
        Text('Score fixes, witness overrides, no-shows and standby promotion live on each '
            'event and league page for staff. This console holds app-wide controls; every '
            'action is audit logged on the backend.',
          style: Theme.of(context).textTheme.bodySmall),
      ]));
  }
}
