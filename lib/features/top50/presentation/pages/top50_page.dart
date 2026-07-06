import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/permission/feature.dart';
import '../../../../core/permission/permission_service.dart';
import '../../../../core/widgets/upgrade_prompt.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../widgets/leaderboard_row.dart';

/// Rendered as the Top 50 tab's body inside [MainShell].
class Top50Page extends StatefulWidget {
  const Top50Page({super.key});

  @override
  State<Top50Page> createState() => _Top50PageState();
}

class _Top50PageState extends State<Top50Page> {
  late final Future<List<LeaderboardEntry>> _future =
      GetIt.instance<LeaderboardRepository>().getLeaderboard();

  void _onChallenge(LeaderboardEntry entry) {
    final permissionService = GetIt.instance<PermissionService>();
    if (!permissionService.can(Feature.challengePlayer)) {
      UpgradePrompt.show(context, message: 'Upgrade to challenge other players.');
      return;
    }

    // Stub — the real ranking/challenge engine is backend/Phase 2.
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Challenge sent'),
        content: Text('Your challenge to ${entry.playerName} has been sent (mock).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LeaderboardEntry>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final entries = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return LeaderboardRow(entry: entry, onChallenge: () => _onChallenge(entry));
          },
        );
      },
    );
  }
}
