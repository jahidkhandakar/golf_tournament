import 'package:flutter/material.dart';
import '../../domain/indoor.dart';

/// League home, members only. Five tabs. Bookings, fees, skins and KP entry
/// all live at the front desk; the app shows week, course, results, prizes
/// and standings. Feed is admin postings only; no chat indoors.
class LeagueHomePage extends StatelessWidget {
  const LeagueHomePage({super.key, required this.league, this.isMember = true, this.isAdmin = false, this.currentUser = 'You'});
  final IndoorLeague league; final bool isMember; final bool isAdmin; final String currentUser;

  @override
  Widget build(BuildContext context) {
    if (!isMember) {
      return Scaffold(appBar: AppBar(title: Text(league.name)), body: const Center(child: Padding(
        padding: EdgeInsets.all(24), child: Text('Members only. Results, standings and the feed are visible to league members.', textAlign: TextAlign.center))));
    }
    final wk = league.currentWeek.clamp(1, league.seasonWeeks);
    final course = league.courses[wk - 1];
    final published = league.publishedWeeks.contains(wk);
    final weekRounds = league.rounds.where((r) => r.weekNumber == wk && !r.isMakeup).toList();
    final myFlight = league.members.where((m) => m.player == currentUser).isEmpty ? null
        : league.members.firstWhere((m) => m.player == currentUser).flight;
    final flights = <int, List<FlightMember>>{};
    for (final m in league.members) { flights.putIfAbsent(m.flight ?? 0, () => []).add(m); }
    for (final l in flights.values) { l.sort((a, b) => a.totalScore.compareTo(b.totalScore)); }
    final myMissed = league.missedFor(currentUser);

    return DefaultTabController(length: 5, child: Scaffold(
      appBar: AppBar(title: Text(league.name), bottom: const TabBar(isScrollable: true, tabs: [
        Tab(text: 'This Week'), Tab(text: 'Weekly Results'), Tab(text: 'Year To Date'),
        Tab(text: 'All Flights'), Tab(text: 'Feed')])),
      body: TabBarView(children: [
        ListView(padding: const EdgeInsets.all(16), children: [
          Text('Week $wk of ${league.seasonWeeks}', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(course.course.isEmpty ? 'Course TBD' : course.course, style: Theme.of(context).textTheme.titleLarge),
          Text('Rating ${course.rating.toStringAsFixed(1)}  ·  Slope ${course.slope}'),
          const SizedBox(height: 12),
          if (isAdmin) Text('Entered so far: ${weekRounds.where((r) => r.skinsIn).length} in Skins  ·  ${weekRounds.where((r) => r.kpIn).length} in KP',
            style: const TextStyle(fontWeight: FontWeight.w600)),
          if (myMissed.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 10),
            child: Text('Your missed rounds to make up: ${myMissed.map((c) => 'Week ${c.week}, ${c.course}').join('  ·  ')}',
              style: const TextStyle(color: Colors.red))),
          const SizedBox(height: 8),
          Text('Results publish by Tuesday 1800.', style: Theme.of(context).textTheme.bodySmall),
        ]),
        ListView(padding: const EdgeInsets.all(16), children: [
          if (!published)
            const Text('Results for this week publish by Tuesday 1800. Scores stay hidden until the admin publishes.')
          else ...[
            Text('Weekly prizes', style: Theme.of(context).textTheme.titleMedium),
            for (final p in league.weekPrizes[wk] ?? const <WeeklyPrize>[])
              Padding(padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('Flight ${p.flight} - ${p.player} - Low ${p.type} ${p.score} - ${p.prize}')),
            if ((league.weekPrizes[wk] ?? const []).isEmpty) const Text('Low gross and low net per flight appear here at publish.'),
            const SizedBox(height: 12),
            Text('Skins winners', style: Theme.of(context).textTheme.titleMedium),
            for (final s in league.weekSkins[wk] ?? const <SkinResult>[])
              Row(children: [
                Expanded(flex: 3, child: Text(s.player)),
                Expanded(flex: 3, child: Text('Hole ${s.hole}')),
                Expanded(flex: 4, child: Text('${s.label} ${s.score}'.trim())),
                Expanded(flex: 2, child: Text('\$${s.amount.toStringAsFixed(0)}', textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
              ]),
            if ((league.weekSkins[wk] ?? const []).isEmpty) const Text('No skins won this week.'),
            const SizedBox(height: 12),
            Text('KP winners', style: Theme.of(context).textTheme.titleMedium),
            for (final k in league.weekKps[wk] ?? const <KpResult>[])
              Row(children: [
                Expanded(child: Text(k.player)),
                Text('Hole ${k.hole}  ·  ${k.distanceFeet.toStringAsFixed(1)} ft'),
                SizedBox(width: 70, child: Text('\$${k.prize.toStringAsFixed(0)}', textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
              ]),
            if ((league.weekKps[wk] ?? const []).isEmpty) const Text('No KPs recorded this week.'),
          ],
        ]),
        // YEAR TO DATE: the user's own flight and standing within it.
        ListView(padding: const EdgeInsets.all(16), children: [
          Text(myFlight == null ? 'Your flight allocates after your first 3 rounds.' : 'Your flight: $myFlight',
            style: Theme.of(context).textTheme.titleMedium),
          for (final m in flights[myFlight] ?? const <FlightMember>[])
            Builder(builder: (context) {
              final missing = league.missedFor(m.player).isNotEmpty;
              final showDetail = isAdmin || m.player == currentUser;
              return ListTile(dense: true, title: Text(m.player),
                subtitle: Text('${m.roundsPlayed} of ${league.seasonWeeks} rounds'
                    '${showDetail && missing ? '   Missed: ${league.missedFor(m.player).map((c) => 'Week ${c.week} ${c.course}').join(', ')}' : ''}',
                  style: TextStyle(color: showDetail && missing ? Colors.red : null, fontSize: 12)),
                trailing: Text('${m.totalScore}', style: TextStyle(fontWeight: FontWeight.w600,
                  color: missing ? Colors.red : null)));
            }),
          if (isAdmin && league.missedByPlayer.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Missed rounds, all players (admin)', style: Theme.of(context).textTheme.titleMedium),
            for (final e in league.missedByPlayer.entries)
              Text('${e.key}: ${e.value.map((c) => 'Week ${c.week}  ${c.course}').join(', ')}',
                style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],
        ]),
        // ALL FLIGHTS: simple scroll, top flight first.
        ListView(padding: const EdgeInsets.all(16), children: [
          for (final f in (flights.keys.toList()..sort())) ...[
            Text(f == 0 ? 'Unassigned' : 'Flight $f', style: Theme.of(context).textTheme.titleMedium),
            for (final (i, m) in (flights[f] ?? const <FlightMember>[]).indexed)
              Row(children: [
                SizedBox(width: 26, child: Text('${i + 1}.')),
                Expanded(child: Text(m.player,
                  style: TextStyle(color: league.missedFor(m.player).isNotEmpty ? Colors.red : null))),
                Text('${m.totalScore}'),
              ]),
            const SizedBox(height: 10),
          ],
          if (league.members.isEmpty) const Text('Flights appear as players complete 3 rounds.'),
        ]),
        ListView(padding: const EdgeInsets.all(16), children: const [
          Text('League feed. Announcements posted by the league creator only. Everyone else reads; no chat in indoor leagues.'),
        ]),
      ])));
  }
}
