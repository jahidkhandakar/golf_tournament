import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

const _gold = Color(0xFFFFD700);
const _silver = Color(0xFFC0C0C0);
const _bronze = Color(0xFFCD7F32);

/// Shows a gold/silver/bronze trophy for ranks 1-3, or the plain number for
/// 4th place onward. Shared by the Top 50 tab and the Club leaderboard.
class RankMedal extends StatelessWidget {
  const RankMedal({super.key, required this.rank});

  final int rank;

  Color? _medalColor() {
    switch (rank) {
      case 1:
        return _gold;
      case 2:
        return _silver;
      case 3:
        return _bronze;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final medalColor = _medalColor();
    return SizedBox(
      width: 28,
      child: medalColor != null
          ? Icon(Icons.emoji_events, color: medalColor, size: 24)
          : Text(
              '$rank',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading3(AppColors.grey),
            ),
    );
  }
}
