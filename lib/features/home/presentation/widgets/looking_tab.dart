import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/permission/feature.dart';
import '../../../../core/permission/permission_service.dart';
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
  late final Future<List<LookingPost>> _future = GetIt.instance<LookingRepository>().getLookingPosts();

  void _showMock(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onPost() {
    final permissionService = GetIt.instance<PermissionService>();
    if (permissionService.can(Feature.lookingToPlayPost)) {
      _showMock('Post created (mock)');
    } else {
      UpgradePrompt.show(context, message: 'Upgrade to post to Looking to Play.');
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
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return LookingPostCard(
                    post: post,
                    onInvite: () => _showMock('Invited ${post.playerName} to your gaggle (mock)'),
                    onMessage: () => _showMock('Opening chat with ${post.playerName} (mock)'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
