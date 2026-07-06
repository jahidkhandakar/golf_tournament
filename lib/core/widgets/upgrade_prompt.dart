import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Bottom sheet shown when a user taps a locked feature.
///
/// The [message] is expected to come from the backend once [PermissionService]
/// is wired up (e.g. "Upgrade to Pro to unlock Top 50").
class UpgradePrompt {
  UpgradePrompt._();

  static Future<void> show(
    BuildContext context, {
    required String message,
    VoidCallback? onUpgrade,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, color: AppColors.gold, size: 40),
                const SizedBox(height: 16),
                Text(
                  'Upgrade required',
                  style: AppTextStyles.heading3(textColor),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(
                    isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      onUpgrade?.call();
                    },
                    child: const Text('Upgrade'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Not now'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
