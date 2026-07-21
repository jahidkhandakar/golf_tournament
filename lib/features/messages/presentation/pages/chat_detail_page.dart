import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/assets/app_images.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../domain/entities/chat_product.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/message_repository.dart';
import '../widgets/message_bubble.dart';

/// Full-screen 1-on-1 chat, pushed on top of the shell (no bottom nav).
/// Messaging is always free — no permission gate here. When the conversation
/// came from a marketplace listing, the item is pinned at the top.
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

  @override
  void initState() {
    super.initState();
    // On a fresh product chat, prefill the standard opening question so the
    // buyer isn't staring at a blank box.
    final product = widget.conversation.product;
    if (product != null) {
      _future.then((messages) {
        if (mounted && messages.isEmpty && _controller.text.isEmpty) {
          _controller.text = 'Hi, is the ${product.title} still available?';
        }
      });
    }
  }

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
    final product = widget.conversation.product;

    return Scaffold(
      appBar: AppBar(title: Text(widget.conversation.participantName)),
      body: Column(
        children: [
          if (product != null) _PinnedProduct(product: product),
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

/// The marketplace item this chat is about, pinned below the app bar.
class _PinnedProduct extends StatelessWidget {
  const _PinnedProduct({required this.product});

  final ChatProduct product;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Material(
      color: AppColors.gold.withValues(alpha: isDark ? 0.16 : 0.09),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => ImagePreview.show(context, AppImages.equipment(product.imageKey)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  AppImages.equipment(product.imageKey),
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  cacheWidth: 120,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 44,
                    height: 44,
                    color: AppColors.gold.withValues(alpha: 0.2),
                    child: Icon(product.icon, color: AppColors.goldDark),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: AppTextStyles.bodyBold(primaryText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('Marketplace item', style: AppTextStyles.caption(secondaryText)),
                ],
              ),
            ),
            Text(product.price, style: AppTextStyles.heading3(AppColors.goldDark)),
          ],
        ),
      ),
    );
  }
}
