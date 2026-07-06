import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/permission/feature.dart';
import '../../../../core/permission/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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

  // Local demo counter for the free-tier trial allowance. Once
  // PermissionService is wired to the backend, `can(Feature.createOuting)`
  // itself will reflect whether trials are exhausted — this stays as the
  // visible "X of 2 free left" state until then.
  static const int _freeTrialLimit = 2;
  int _trialsUsed = 0;

  void _showMock(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onCreateOuting() {
    final permissionService = GetIt.instance<PermissionService>();
    if (!permissionService.can(Feature.createOuting)) {
      UpgradePrompt.show(context, message: 'Upgrade to create unlimited outings.');
      return;
    }
    if (_trialsUsed >= _freeTrialLimit) {
      UpgradePrompt.show(
        context,
        message: "You've used your $_freeTrialLimit free outings. Upgrade for unlimited outings.",
      );
      return;
    }
    setState(() => _trialsUsed++);
    _showMock('Outing created (mock)');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final trialsRemaining = (_freeTrialLimit - _trialsUsed).clamp(0, _freeTrialLimit);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  trialsRemaining > 0 ? '$trialsRemaining of $_freeTrialLimit free left' : 'Free trials used',
                  style: AppTextStyles.caption(secondaryText),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _onCreateOuting,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create Outing'),
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
              final outings = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: outings.length,
                itemBuilder: (context, index) {
                  final outing = outings[index];
                  return OutingCard(
                    outing: outing,
                    onJoin: () => _showMock('Joined "${outing.title}" (mock)'),
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
