import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/play/play_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Shows the tee times the user is locked into from accepted challenges.
/// Each row pairs the user with their opponent at a shared tee time.
class TeeSheetPage extends StatelessWidget {
  const TeeSheetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final play = GetIt.instance<PlayController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(title: const Text('Tee Sheet')),
      body: ValueListenableBuilder<List<TeeSheetEntry>>(
        valueListenable: play.teeSheet,
        builder: (context, entries, _) {
          if (entries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No tee times yet.\nChallenge a player from Top 50 to get paired into a tee time.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(secondaryText),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: Container(
                    width: 56,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      entry.teeTime,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption(AppColors.goldDark).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  title: Text('You & ${entry.opponentName}', style: AppTextStyles.bodyBold(primaryText)),
                  subtitle: Text(
                    '${entry.tournamentName} · ${entry.courseName}\n${entry.date}',
                    style: AppTextStyles.caption(secondaryText),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
