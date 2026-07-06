import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../widgets/conversation_tile.dart';

/// Rendered as the Messages tab's body inside [MainShell]. Messaging is
/// always free — there's no permission gate anywhere in this feature.
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
    return FutureBuilder<List<Conversation>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final conversations = snapshot.data!;
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
  }
}
