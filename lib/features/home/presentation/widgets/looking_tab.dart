import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/permission/feature.dart';
import '../../../../core/permission/permission_service.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/upgrade_prompt.dart';
import '../../domain/entities/looking_post.dart';
import '../../domain/repositories/looking_repository.dart';
import 'looking_post_card.dart';

class LookingTab extends StatefulWidget {
  const LookingTab({super.key});

  @override
  State<LookingTab> createState() => _LookingTabState();
}

class _LookingTabState extends State<LookingTab> {
  late Future<List<LookingPost>> _future = _load();

  Future<List<LookingPost>> _load() => GetIt.instance<LookingRepository>().getLookingPosts();

  void _showMock(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onPost() async {
    final permissionService = GetIt.instance<PermissionService>();
    if (!permissionService.can(Feature.lookingToPlayPost)) {
      UpgradePrompt.show(context, message: 'Upgrade to post to Looking to Play.');
      return;
    }
    final created = await context.push(AppRoutes.createLookingPost);
    if (created == true) {
      setState(() {
        _future = _load();
      });
      if (mounted) _showMock('Post created');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _onPost,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Post'),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<LookingPost>>(
            future: _future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final posts = snapshot.data!;
              return ListView(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                    // Highlighted so Indoor Golf stands out from the plain rows.
                    // Colour/border go on the ListTile itself (tileColor + shape)
                    // so they paint on the tile's own Material — wrapping it in a
                    // decorated Container would hide the ink splash.
                    child: ListTile(
                      tileColor: AppColors.gold.withValues(alpha: 0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.gold),
                      ),
                      leading: const Icon(Icons.sports_esports_outlined,
                          color: AppColors.goldDark),
                      title: const Text('Indoor Golf',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle:
                          const Text('Simulator leagues and Sim Social Rounds'),
                      trailing: const Icon(Icons.chevron_right,
                          color: AppColors.goldDark),
                      onTap: () => context.push(AppRoutes.indoor),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.people_outline),
                    title: const Text('Browse golfers near you'),
                    trailing: const Icon(Icons.chevron_right),
                    // Route to the Users tab (same golfers list) rather than a
                    // separate pushed page.
                    onTap: () => context.go(AppRoutes.profile),
                  ),
                  for (final post in posts)
                    LookingPostCard(
                      post: post,
                      onInvite: () => _showMock('Invited ${post.playerName} to your club (mock)'),
                      onMessage: () => _showMock('Opening chat with ${post.playerName} (mock)'),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
