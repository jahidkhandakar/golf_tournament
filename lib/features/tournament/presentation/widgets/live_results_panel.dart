import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/contest_config.dart';
import '../../domain/live_results.dart';

/// Player-facing live results for a tournament: the leaderboard, skins, and
/// placard winners exactly as the entry screen writes them, updating in real
/// time. Shows IN PROGRESS until an authorized user presses Final Results,
/// then flips to FINAL. Renders nothing until entry has started.
class LiveResultsPanel extends StatefulWidget {
  const LiveResultsPanel({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  State<LiveResultsPanel> createState() => _LiveResultsPanelState();
}

class _LiveResultsPanelState extends State<LiveResultsPanel> {
  LiveResults? _live;

  @override
  void initState() {
    super.initState();
    _live = GetIt.instance<LiveResultsRegistry>().existing(widget.tournamentId);
    _live?.addListener(_onLive);
  }

  @override
  void dispose() {
    _live?.removeListener(_onLive);
    super.dispose();
  }

  void _onLive() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final live = _live;
    if (live == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final board = live.liveBoard.where((r) => r.thru > 0).toList();
    final skins = live.skins;
    final winners = live.contestWinners;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: live.isFinal ? AppColors.success : AppColors.gold,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Results', style: AppTextStyles.heading3(primaryText)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (live.isFinal ? AppColors.success : AppColors.gold).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  live.isFinal ? 'FINAL' : 'IN PROGRESS',
                  style: AppTextStyles.caption(live.isFinal ? AppColors.success : AppColors.goldDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (board.isEmpty)
            Text('Waiting for the first scores.', style: AppTextStyles.body(secondaryText))
          else ...[
            for (var i = 0; i < board.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(width: 24, child: Text('${i + 1}', style: AppTextStyles.bodyBold(secondaryText))),
                    Expanded(child: Text(board[i].player, style: AppTextStyles.body(primaryText))),
                    Text('${board[i].strokes}', style: AppTextStyles.bodyBold(primaryText)),
                    const SizedBox(width: 8),
                    Text('thru ${board[i].thru}', style: AppTextStyles.caption(secondaryText)),
                  ],
                ),
              ),
          ],
          if (skins.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Skins', style: AppTextStyles.bodyBold(primaryText)),
            const SizedBox(height: 4),
            for (final s in skins)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(width: 56, child: Text('Hole ${s.hole}', style: AppTextStyles.caption(secondaryText))),
                    Expanded(
                      child: Text(
                        '${s.winner}${s.wonWithPar ? ' (par)' : ''}${s.deductPercent > 0 ? ' (${s.deductPercent}% deducted)' : ''}',
                        style: AppTextStyles.body(primaryText),
                      ),
                    ),
                    if (s.value > 0)
                      Text('\$${s.value.toStringAsFixed(0)}', style: AppTextStyles.bodyBold(AppColors.goldDark)),
                  ],
                ),
              ),
          ],
          if (winners.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('KPs and long drives', style: AppTextStyles.bodyBold(primaryText)),
            const SizedBox(height: 4),
            for (final w in winners)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 56,
                      child: Text('Hole ${w.hole}', style: AppTextStyles.caption(secondaryText)),
                    ),
                    Expanded(
                      child: Text(
                        '${w.isLongDrive ? 'LD' : 'KP'}'
                        '${w.category == ContestCategory.open ? '' : ' - ${w.category.label}'}'
                        '  ${w.playerName}',
                        style: AppTextStyles.body(primaryText),
                      ),
                    ),
                    if (w.distance != null && w.distance!.isNotEmpty)
                      Text(w.distance!, style: AppTextStyles.caption(secondaryText)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
