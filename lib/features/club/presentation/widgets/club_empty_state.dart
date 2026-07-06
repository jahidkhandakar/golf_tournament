import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Shown when the user hasn't joined (or started) a club yet — the common
/// case for brand-new users, so this needs to be a real, useful screen
/// rather than a bare "empty" label.
class ClubEmptyState extends StatelessWidget {
  const ClubEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sports_golf_outlined, size: 56, color: AppColors.gold),
            const SizedBox(height: 16),
            Text(
              "You're not in a club yet",
              style: AppTextStyles.heading3(primaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _EmptyStateOption(
              question: 'No club yet?',
              hint: 'Find one near you',
              buttonLabel: 'Browse from Home',
              onPressed: () => context.go(AppRoutes.home),
              primaryText: primaryText,
              secondaryText: secondaryText,
            ),
            const SizedBox(height: 20),
            _EmptyStateOption(
              question: 'No clubs in your zone?',
              hint: 'Be the first to start one',
              buttonLabel: 'Start a Club',
              onPressed: () => context.push(AppRoutes.createClub),
              primaryText: primaryText,
              secondaryText: secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateOption extends StatelessWidget {
  const _EmptyStateOption({
    required this.question,
    required this.hint,
    required this.buttonLabel,
    required this.onPressed,
    required this.primaryText,
    required this.secondaryText,
  });

  final String question;
  final String hint;
  final String buttonLabel;
  final VoidCallback onPressed;
  final Color primaryText;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(question, style: AppTextStyles.bodyBold(primaryText), textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(hint, style: AppTextStyles.body(secondaryText), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        OutlinedButton(onPressed: onPressed, child: Text(buttonLabel)),
      ],
    );
  }
}
