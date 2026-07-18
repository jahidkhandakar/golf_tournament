import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/location/location_state.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../widgets/conversation_tile.dart';

/// Rendered as the Messages tab's body inside [MainShell]. Messaging is
/// always free, but the list is scoped to golfers within the current search
/// radius (60 mi, or 120 mi for rural villages) — see [LocationState].
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late final Future<List<Conversation>> _future =
      GetIt.instance<ConversationRepository>().getConversations();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return FutureBuilder<List<Conversation>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final allConversations = snapshot.data!;
        return ValueListenableBuilder<int>(
          valueListenable: GetIt.instance<LocationState>().radiusMiles,
          builder: (context, radius, _) {
            final conversations =
                allConversations.where((c) => c.distanceMiles <= radius).toList();
            if (conversations.isEmpty) {
              return Center(
                child: Text('No conversations within $radius mi', style: AppTextStyles.body(secondaryText)),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: conversations.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return ConversationTile(
                  conversation: conversation,
                  onTap: () => context.push(AppRoutes.chatDetail(conversation.id), extra: conversation),
                );
              },
            );
          },
        );
      },
    );
  }
}
