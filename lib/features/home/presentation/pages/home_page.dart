import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/location/location_state.dart';
import '../../../../core/router/app_routes.dart';
import '../widgets/club_rounds_tab.dart';
import '../widgets/looking_tab.dart';
import '../widgets/outings_tab.dart';
import '../widgets/sponsored_banner.dart';
import '../widgets/zone_context_line.dart';

enum _HomeTab { clubs, outings, looking }

/// Rendered as the Home tab's body inside [MainShell] — the shell supplies
/// the AppBar, Drawer and bottom navigation, so this only owns the
/// sponsored banner, zone line, segmented control, and the 3 tab bodies.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _HomeTab _selected = _HomeTab.clubs;

  @override
  Widget build(BuildContext context) {
    final locationState = GetIt.instance<LocationState>();

    return Column(
      children: [
        const SponsoredBanner(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.marketplace),
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Browse Global Marketplace'),
            ),
          ),
        ),
        ValueListenableBuilder<String>(
          valueListenable: locationState.currentZone,
          builder: (context, zone, _) => ZoneContextLine(
            zone: zone,
            radiusMiles: locationState.radiusMiles.value,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<_HomeTab>(
            segments: const [
              ButtonSegment(value: _HomeTab.clubs, label: Text('Clubs')),
              ButtonSegment(value: _HomeTab.outings, label: Text('Outings')),
              ButtonSegment(value: _HomeTab.looking, label: Text('Looking')),
            ],
            selected: {_selected},
            onSelectionChanged: (selection) => setState(() => _selected = selection.first),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: IndexedStack(
            index: _HomeTab.values.indexOf(_selected),
            children: const [
              ClubRoundsTab(),
              OutingsTab(),
              LookingTab(),
            ],
          ),
        ),
      ],
    );
  }
}
