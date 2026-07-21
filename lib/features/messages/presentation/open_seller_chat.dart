import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../domain/entities/chat_product.dart';
import '../domain/repositories/conversation_repository.dart';

/// Opens (or starts) a chat with a marketplace seller about a specific item.
/// The item is pinned to the conversation so the thread stays self-explanatory.
/// Shared by the global Marketplace detail and the club Marketplace tab.
Future<void> openSellerChat(
  BuildContext context, {
  required String sellerName,
  required String title,
  required String price,
  required IconData icon,
  required String imageKey,
}) async {
  final product =
      ChatProduct(title: title, price: price, sellerName: sellerName, icon: icon, imageKey: imageKey);
  final conversation = await GetIt.instance<ConversationRepository>()
      .getOrCreateProductConversation(sellerName: sellerName, product: product);
  if (context.mounted) {
    context.push(AppRoutes.chatDetail(conversation.id), extra: conversation);
  }
}
