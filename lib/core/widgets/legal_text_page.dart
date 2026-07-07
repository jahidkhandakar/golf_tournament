import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Generic scrollable text page for Terms & Conditions / Privacy Policy —
/// placeholder copy until real legal text is provided.
class LegalTextPage extends StatelessWidget {
  const LegalTextPage({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(body, style: AppTextStyles.body(primaryText)),
      ),
    );
  }
}
