import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/labels/app_labels.dart';
import '../../../../core/location/location_state.dart';
import '../../../../core/permission/feature.dart';
import '../../../../core/permission/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/play/trial_controller.dart';
import '../../../../core/widgets/upgrade_prompt.dart';
import '../../domain/entities/outing.dart';
import '../../domain/repositories/outing_repository.dart';
import 'outing_card.dart';

class OutingsTab extends StatefulWidget {
  const OutingsTab({super.key});

  @override
  State<OutingsTab> createState() => _OutingsTabState();
}

class _OutingsTabState extends State<OutingsTab> {
  late final Future<List<Outing>> _future = GetIt.instance<OutingRepository>().getOutings();

  // The two-counter free trial allowance lives in TrialController (shared
  // state), not in this widget, so the counts survive navigation. This tab
  // consumes the home counter; joining an outside-zone event consumes the
  // travel counter. Server side once the backend is wired.
  final TrialController _trials = GetIt.instance<TrialController>();

  void _showMock(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onCreateOuting() {
    final permissionService = GetIt.instance<PermissionService>();
    if (!permissionService.can(Feature.createOuting)) {
      UpgradePrompt.show(context, message: 'Upgrade to create unlimited pickups.');
      return;
    }
    if (!_trials.canUseHomeTrial) {
      UpgradePrompt.show(
        context,
        message: "You've used your ${TrialController.limitPerCounter} free home pickups. Upgrade for unlimited pickups.",
      );
      return;
    }
    setState(() => _trials.useHomeTrial());
    _showMock('Pickup created (mock)');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final trialsRemaining = _trials.homeRemaining;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  trialsRemaining > 0
                      ? '$trialsRemaining of ${TrialController.limitPerCounter} home trials left'
                      : 'Home trials used',
                  style: AppTextStyles.caption(secondaryText),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _onCreateOuting,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create ${AppLabels.pickup}'),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Outing>>(
            future: _future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final allOutings = snapshot.data!;
              return ValueListenableBuilder<int>(
                valueListenable: GetIt.instance<LocationState>().radiusMiles,
                builder: (context, radius, _) {
                  final outings = allOutings.where((o) => o.distanceMiles <= radius).toList();
                  return ListView(
                    padding: const EdgeInsets.only(top: 4, bottom: 16),
                    children: [
                      if (outings.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text('No pickups within $radius mi', style: AppTextStyles.body(secondaryText)),
                          ),
                        )
                      else
                        for (final outing in outings)
                          OutingCard(
                            outing: outing,
                            onJoin: () => _showMock('Joined "${outing.title}" (mock)'),
                          ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
