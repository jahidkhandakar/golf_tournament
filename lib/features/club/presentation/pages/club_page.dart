import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/club/active_club_state.dart';
import '../../../../core/play/play_controller.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/club.dart';
import '../../domain/repositories/club_repository.dart';
import '../widgets/chat_tab.dart';
import '../widgets/club_empty_state.dart';
import '../widgets/club_header.dart';
import '../widgets/feed_tab.dart';
import '../widgets/gallery_tab.dart';
import '../widgets/leaderboard_tab.dart';
import '../widgets/marketplace_tab.dart';
import '../widgets/results_tab.dart';

const _tabLabels = ['Feed', 'Leaderboard', 'Results', 'Chat', 'Marketplace', 'Gallery'];

/// Rendered as the Club tab's body inside [MainShell]. Shows the club the
/// user has selected in My Clubs (via [ActiveClubState]); the header switcher
/// lets them change it without leaving the tab.
class ClubPage extends StatelessWidget {
  const ClubPage({super.key});

  ClubRepository get _clubRepo => GetIt.instance<ClubRepository>();

  void _showSwitcher(BuildContext pageContext) {
    final activeClub = GetIt.instance<ActiveClubState>();
    final joined = GetIt.instance<PlayController>().joinedClubs.value;

    showModalBottomSheet<void>(
      context: pageContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: FutureBuilder<List<Club>>(
            future: _clubRepo.getAllClubs(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator());
              }
              final myClubs = snapshot.data!.where((c) => joined.contains(c.name)).toList();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Text('Switch club', style: Theme.of(sheetContext).textTheme.headlineSmall),
                  for (final club in myClubs)
                    ListTile(
                      leading: const Icon(Icons.sports_golf_outlined, color: AppColors.gold),
                      title: Text(club.name),
                      subtitle: Text(club.location),
                      onTap: () {
                        activeClub.select(club.id);
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.search),
                    title: const Text('Find more clubs'),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      pageContext.push(AppRoutes.myClubs);
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeClub = GetIt.instance<ActiveClubState>();

    return ValueListenableBuilder<String>(
      valueListenable: activeClub.activeClubId,
      builder: (context, clubId, _) {
        return FutureBuilder<Club?>(
          future: _clubRepo.getClub(clubId),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final club = snapshot.data;
            if (club == null) return const ClubEmptyState();
            return _ClubHome(club: club, onSwitch: () => _showSwitcher(context));
          },
        );
      },
    );
  }
}

class _ClubHome extends StatelessWidget {
  const _ClubHome({required this.club, required this.onSwitch});

  final Club club;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabLabels.length,
      child: Column(
        children: [
          ClubHeader(club: club, onSwitch: onSwitch),
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [for (final label in _tabLabels) Tab(text: label)],
          ),
          Expanded(
            child: TabBarView(
              children: [
                FeedTab(members: club.members),
                LeaderboardTab(members: club.members),
                ResultsTab(members: club.members),
                ChatTab(members: club.members),
                MarketplaceTab(clubName: club.name, members: club.members),
                GalleryTab(clubName: club.name),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
