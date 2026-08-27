import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/labels/app_labels.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/club_round.dart';
import '../../domain/entities/looking_post.dart';
import '../../domain/entities/outing.dart';
import '../../domain/repositories/club_round_repository.dart';
import '../../domain/repositories/looking_repository.dart';
import '../../domain/repositories/outing_repository.dart';
import '../widgets/club_round_card.dart';
import '../widgets/looking_post_card.dart';
import '../widgets/outing_card.dart';

typedef _SearchData = ({List<ClubRound> clubRounds, List<Outing> outings, List<LookingPost> lookingPosts});

/// Searches across Clubs, Outings, and Looking to Play posts — the content
/// already shown on Home. Opened from the search icon in Home's AppBar.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _queryController = TextEditingController();
  late final Future<_SearchData> _future = _load();

  Future<_SearchData> _load() async {
    final clubRounds = await GetIt.instance<ClubRoundRepository>().getClubRounds();
    final outings = await GetIt.instance<OutingRepository>().getOutings();
    final lookingPosts = await GetIt.instance<LookingRepository>().getLookingPosts();
    return (clubRounds: clubRounds, outings: outings, lookingPosts: lookingPosts);
  }

  void _showMock(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  bool _matches(String query, List<String> fields) {
    return fields.any((field) => field.toLowerCase().contains(query));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final query = _queryController.text.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _queryController,
          autofocus: true,
          onChanged: (_) => setState(() {}),
          cursorColor: AppColors.white,
          style: AppTextStyles.body(AppColors.white),
          decoration: InputDecoration(
            hintText: 'Search clubs, pickups, players...',
            hintStyle: AppTextStyles.body(AppColors.white),
            border: InputBorder.none,
          ),
        ),
      ),
      body: FutureBuilder<_SearchData>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (query.isEmpty) {
            return Center(
              child: Text('Start typing to search', style: AppTextStyles.body(secondaryText)),
            );
          }

          final data = snapshot.data!;
          final clubRounds = data.clubRounds
              .where((c) => _matches(query, [c.clubName, c.courseName, c.format]))
              .toList();
          final outings = data.outings
              .where((o) => _matches(query, [o.title, o.hostName, o.format]))
              .toList();
          final lookingPosts = data.lookingPosts
              .where((p) => _matches(query, [p.playerName, p.location, p.note, ...p.preferredFormats]))
              .toList();

          if (clubRounds.isEmpty && outings.isEmpty && lookingPosts.isEmpty) {
            return Center(
              child: Text('No results for "$query"', style: AppTextStyles.body(secondaryText)),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            children: [
              if (clubRounds.isNotEmpty) ...[
                _SectionLabel(title: 'Clubs', color: primaryText),
                for (final clubRound in clubRounds)
                  ClubRoundCard(
                    clubRound: clubRound,
                    onRequestToPlay: () => _showMock('Requested to play at ${clubRound.clubName} (mock)'),
                    onJoinClub: () => _showMock('Joined ${clubRound.clubName} (mock)'),
                  ),
              ],
              if (outings.isNotEmpty) ...[
                _SectionLabel(title: AppLabels.pickup, color: primaryText),
                for (final outing in outings)
                  OutingCard(outing: outing, onJoin: () => _showMock('Joined "${outing.title}" (mock)')),
              ],
              if (lookingPosts.isNotEmpty) ...[
                _SectionLabel(title: 'Looking to Play', color: primaryText),
                for (final post in lookingPosts)
                  LookingPostCard(
                    post: post,
                    onInvite: () => _showMock('Invited ${post.playerName} to your club (mock)'),
                    onMessage: () => _showMock('Opening chat with ${post.playerName} (mock)'),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(title, style: AppTextStyles.heading3(color)),
    );
  }
}
