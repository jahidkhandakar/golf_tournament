import 'package:flutter/material.dart';

/// Reusable single-message dialog for mock/stub flows (request status,
/// challenge sent, etc.) — one place to keep the "OK to dismiss" pattern.
class InfoDialog {
  InfoDialog._();

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
