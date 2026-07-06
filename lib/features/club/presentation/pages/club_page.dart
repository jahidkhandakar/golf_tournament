import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/club.dart';
import '../../domain/repositories/club_repository.dart';
import '../widgets/chat_tab.dart';
import '../widgets/club_empty_state.dart';
import '../widgets/club_header.dart';
import '../widgets/feed_tab.dart';
import '../widgets/gallery_tab.dart';
import '../widgets/marketplace_tab.dart';
import '../widgets/results_tab.dart';

const _tabLabels = ['Feed', 'Results', 'Chat', 'Marketplace', 'Gallery'];

/// Rendered as the Club tab's body inside [MainShell].
class ClubPage extends StatefulWidget {
  const ClubPage({super.key});

  @override
  State<ClubPage> createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  late final Future<Club?> _future = GetIt.instance<ClubRepository>().getMyClub();

  // Lets you flip between the populated club view and the "no club yet"
  // empty state without editing the mock repo — useful while this screen
  // is still a skeleton. Safe to remove once real membership data flows in.
  bool _previewEmptyState = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Club?>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final club = _previewEmptyState ? null : snapshot.data;

        return Stack(
          children: [
            if (club == null) const ClubEmptyState() else _ClubHome(club: club),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                tooltip: _previewEmptyState ? 'Preview club home' : 'Preview empty state',
                icon: Icon(_previewEmptyState ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _previewEmptyState = !_previewEmptyState),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ClubHome extends StatelessWidget {
  const _ClubHome({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabLabels.length,
      child: Column(
        children: [
          ClubHeader(club: club),
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [for (final label in _tabLabels) Tab(text: label)],
          ),
          Expanded(
            child: TabBarView(
              children: [
                FeedTab(members: club.members),
                const ResultsTab(),
                ChatTab(members: club.members),
                const MarketplaceTab(),
                const GalleryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
