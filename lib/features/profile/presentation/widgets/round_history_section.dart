import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/round.dart';

class RoundHistorySection extends StatelessWidget {
  const RoundHistorySection({super.key, required this.rounds});

  final List<Round> rounds;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    if (rounds.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text('No rounds logged yet.', style: AppTextStyles.body(secondaryText)),
      );
    }

    return Column(
      children: [
        for (final round in rounds)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.golf_course_outlined, color: AppColors.gold),
              title: Text(round.courseName, style: AppTextStyles.bodyBold(primaryText)),
              subtitle: Text(
                '${formatShortDate(round.date)} · ${round.format}',
                style: AppTextStyles.caption(secondaryText),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${round.score}', style: AppTextStyles.bodyBold(primaryText)),
                  Text(
                    round.toPar >= 0 ? '+${round.toPar}' : '${round.toPar}',
                    style: AppTextStyles.caption(secondaryText),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
