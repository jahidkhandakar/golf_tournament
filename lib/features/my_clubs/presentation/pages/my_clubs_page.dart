import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/assets/app_images.dart';
import '../../../../core/club/active_club_state.dart';
import '../../../../core/play/play_controller.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../club/domain/entities/club.dart';
import '../../../club/domain/repositories/club_repository.dart';

/// The clubs hub: the clubs you belong to (tap one to view it on the Club
/// tab) plus a searchable list of more clubs to discover and join.
/// Membership is shared with the Club tab and the challenge flow via
/// [PlayController.joinedClubs].
class MyClubsPage extends StatefulWidget {
  const MyClubsPage({super.key});

  @override
  State<MyClubsPage> createState() => _MyClubsPageState();
}

class _MyClubsPageState extends State<MyClubsPage> {
  late final Future<List<Club>> _future = GetIt.instance<ClubRepository>().getAllClubs();
  final _searchController = TextEditingController();

  PlayController get _play => GetIt.instance<PlayController>();
  ActiveClubState get _activeClub => GetIt.instance<ActiveClubState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openClub(Club club) {
    _activeClub.select(club.id);
    context.go(AppRoutes.club);
  }

  void _joinClub(Club club) {
    _play.joinClub(club.name);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Joined ${club.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(title: const Text('My Clubs')),
      body: FutureBuilder<List<Club>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final allClubs = snapshot.data!;

          return ValueListenableBuilder<Set<String>>(
            valueListenable: _play.joinedClubs,
            builder: (context, joined, _) {
              final query = _searchController.text.trim().toLowerCase();
              final myClubs = allClubs.where((c) => joined.contains(c.name)).toList();
              final discover = allClubs
                  .where((c) => !joined.contains(c.name))
                  .where((c) =>
                      query.isEmpty ||
                      c.name.toLowerCase().contains(query) ||
                      c.location.toLowerCase().contains(query))
                  .toList();

              return ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
          ListTile(
            leading: const Icon(Icons.vpn_key_outlined),
            title: const Text('Join Private Club'),
            subtitle: const Text('Have an access code? Enter it here.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.joinPrivateClub),
          ),
                  _SectionTitle('Your Clubs', secondaryText),
                  for (final club in myClubs)
                    _ClubCard(
                      club: club,
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                      trailing: TextButton(onPressed: () => _openClub(club), child: const Text('View')),
                      onTap: () => _openClub(club),
                    ),
                  const SizedBox(height: 8),
                  _SectionTitle('Discover Clubs', secondaryText),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Search clubs by name or area...',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                      ),
                    ),
                  ),
                  if (discover.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('No other clubs found', style: AppTextStyles.body(secondaryText)),
                    )
                  else
                    for (final club in discover)
                      _ClubCard(
                        club: club,
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                        trailing: ElevatedButton(onPressed: () => _joinClub(club), child: const Text('Join')),
                      ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ClubCard extends StatelessWidget {
  const _ClubCard({
    required this.club,
    required this.primaryText,
    required this.secondaryText,
    required this.trailing,
    this.onTap,
  });

  final Club club;
  final Color primaryText;
  final Color secondaryText;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            AppImages.field(club.name),
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            cacheWidth: 120,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 44,
              height: 44,
              color: AppColors.gold,
              child: const Icon(Icons.sports_golf, color: AppColors.white),
            ),
          ),
        ),
        title: Text(club.name, style: AppTextStyles.bodyBold(primaryText)),
        subtitle: Text(
          '${club.location} · ${club.memberCount} members',
          style: AppTextStyles.caption(secondaryText),
        ),
        trailing: trailing,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.color);

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(title, style: AppTextStyles.caption(color).copyWith(fontWeight: FontWeight.w700)),
    );
  }
}
