import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/photo_avatar.dart';
import '../../domain/entities/club_member.dart';

typedef _FeedPost = ({String author, String timeAgo, String text, int likes});

class FeedTab extends StatelessWidget {
  const FeedTab({super.key, required this.members});

  final List<ClubMember> members;

  List<_FeedPost> _mockPosts() {
    const bodies = [
      "Great turnout for Saturday's round — course was in perfect shape!",
      'Reminder: club championship signups close this Friday.',
      'Anyone up for a twilight nine this week?',
      'New pin placements on 4 and 11 are brutal. Bring your A game.',
    ];
    return List.generate(bodies.length, (i) {
      final author = members.isEmpty ? 'Club Member' : members[i % members.length].name;
      return (author: author, timeAgo: '${i + 1}h ago', text: bodies[i], likes: (i + 1) * 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final posts = _mockPosts();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PhotoAvatar(name: post.author, radius: 16),
                    const SizedBox(width: 10),
                    Expanded(child: Text(post.author, style: AppTextStyles.bodyBold(primaryText))),
                    Text(post.timeAgo, style: AppTextStyles.caption(secondaryText)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(post.text, style: AppTextStyles.body(primaryText)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.favorite_border, size: 16, color: secondaryText),
                    const SizedBox(width: 4),
                    Text('${post.likes}', style: AppTextStyles.caption(secondaryText)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
