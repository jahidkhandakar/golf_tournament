import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/labels/app_labels.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/tag_chip.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/repositories/tournament_repository.dart';

/// Browse tournaments and tap through to register / manage. What you can do on
/// each is decided on the detail screen by your role in that tournament's club.
class TournamentsListPage extends StatefulWidget {
  const TournamentsListPage({super.key});

  @override
  State<TournamentsListPage> createState() => _TournamentsListPageState();
}

class _TournamentsListPageState extends State<TournamentsListPage> {
  late final Future<List<Tournament>> _future =
      GetIt.instance<TournamentRepository>().getAllTournaments();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppLabels.events)),
      body: FutureBuilder<List<Tournament>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final tournaments = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: tournaments.length,
            itemBuilder: (context, index) => _TournamentCard(tournament: tournaments[index]),
          );
        },
      ),
    );
  }
}

class _TournamentCard extends StatelessWidget {
  const _TournamentCard({required this.tournament});

  final Tournament tournament;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final t = tournament;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(AppRoutes.tournamentDetail(t.id), extra: t),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(t.name, style: AppTextStyles.heading3(primaryText))),
                  if (t.isRosterLocked) ...[
                    TagChip(
                      label: 'Locked',
                      background: AppColors.error.withValues(alpha: 0.14),
                      foreground: AppColors.error,
                    ),
                    const SizedBox(width: 6),
                  ],
                  TagChip(
                    label: t.format,
                    background: AppColors.gold.withValues(alpha: 0.16),
                    foreground: AppColors.goldDark,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(t.clubName, style: AppTextStyles.caption(AppColors.goldDark)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: secondaryText),
                  const SizedBox(width: 4),
                  Text('${formatShortDate(t.date)} · ${t.firstTeeTime}', style: AppTextStyles.caption(secondaryText)),
                  const Spacer(),
                  Icon(Icons.groups_outlined, size: 14, color: secondaryText),
                  const SizedBox(width: 4),
                  Text('${t.registeredPlayers}/${t.capacity}', style: AppTextStyles.caption(secondaryText)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
