import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/message_repository.dart';
import '../widgets/message_bubble.dart';

/// Full-screen 1-on-1 chat, pushed on top of the shell (no bottom nav).
/// Messaging is always free — no permission gate here.
class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({super.key, required this.conversation});

  final Conversation conversation;

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  late Future<List<Message>> _future = _loadMessages();

  MessageRepository get _repository => GetIt.instance<MessageRepository>();

  Future<List<Message>> _loadMessages() => _repository.getMessages(widget.conversation.id);

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await _repository.sendMessage(widget.conversation.id, text);
    setState(() => _future = _loadMessages());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.conversation.participantName)),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Message>>(
              future: _future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) => MessageBubble(message: messages[index]),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: _send),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
