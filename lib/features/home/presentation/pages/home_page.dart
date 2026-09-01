import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/labels/app_labels.dart';
import '../../../../core/location/location_state.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/club_rounds_tab.dart';
import '../widgets/looking_tab.dart';
import '../widgets/outings_tab.dart';
import '../widgets/sponsored_banner.dart';

// The first tab lists club-run tournament rounds ([ClubRound]); the internal
// enum stays `tournaments`, but it's displayed via AppLabels.events ("Events").
// Likewise `outings` displays as AppLabels.pickup ("Pickup").
enum _HomeTab { tournaments, outings, looking }

/// Rendered as the Home tab's body inside [MainShell]. Kept deliberately lean:
/// the segmented control leads, followed by a single compact context bar
/// (zone + a Marketplace shortcut) and the sponsored ad window. The sponsored
/// window is pinned here (outside the tab lists) so it stays fixed and visible
/// while only the lower category content scrolls.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _HomeTab _selected = _HomeTab.tournaments;

  @override
  Widget build(BuildContext context) {
    final locationState = GetIt.instance<LocationState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      children: [
        // Fixed header: category tabs + context bar + sponsored ad window.
        // Given an opaque background so scrolling content can never bleed
        // through the transparent gaps behind it.
        ColoredBox(
          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(children: [
                  for (final (t, label, fx) in [
                    (_HomeTab.tournaments, AppLabels.events, 5),
                    (_HomeTab.outings, AppLabels.pickup, 5),
                    (_HomeTab.looking, 'Looking to Play', 8),
                  ])
                    Expanded(
                      flex: fx,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => setState(() => _selected = t),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _selected == t ? AppColors.navy : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _selected == t ? AppColors.navy : AppColors.greyLight),
                            ),
                            child: Text(label,
                              maxLines: 1, overflow: TextOverflow.fade, softWrap: false,
                              style: TextStyle(fontSize: 13,
                                color: _selected == t ? Colors.white : null,
                                fontWeight: _selected == t ? FontWeight.w600 : FontWeight.w400)),
                          ),
                        ),
                      ),
                    ),
                ]),
              ),
              _ContextBar(locationState: locationState, secondaryText: secondaryText),
              // Fixed sponsored ad window — stays put while the tab content scrolls.

          // Indoor Golf entry: compact, centered, deliberately secondary to the
          // three outdoor options above. One-line move if placement changes.
          Center(child: TextButton.icon(
            icon: const Icon(Icons.sports_golf, size: 18),
            label: const Text('Indoor Golf'),
            onPressed: () => context.push(AppRoutes.indoor),
          )),
              const SponsoredBanner(),
            ],
          ),
        ),
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

/// One-line bar: tappable zone + radius on the left, a Marketplace shortcut
/// on the right.
class _ContextBar extends StatelessWidget {
  const _ContextBar({required this.locationState, required this.secondaryText});

  final LocationState locationState;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => context.push(AppRoutes.location),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ValueListenableBuilder<String>(
                  valueListenable: locationState.currentZone,
                  builder: (context, zone, _) => Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: secondaryText),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '$zone · ${locationState.radiusMiles.value} mi',
                          style: AppTextStyles.caption(secondaryText),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.push(AppRoutes.marketplace),
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Marketplace', style: AppTextStyles.caption(AppColors.goldDark)),
                const Icon(Icons.chevron_right, size: 16, color: AppColors.goldDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
