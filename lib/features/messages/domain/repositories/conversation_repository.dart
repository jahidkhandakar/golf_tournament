import '../entities/chat_product.dart';
import '../entities/conversation.dart';

abstract class ConversationRepository {
  Future<List<Conversation>> getConversations();

  /// Returns the existing conversation with this participant, or starts a
  /// new one — used by "Message" buttons on golfer profiles.
  Future<Conversation> getOrCreateConversationWith(String participantName);

  /// Returns the existing conversation about this exact product (same seller
  /// + same item), or starts a new one pinned to the product. Messaging a
  /// seller about a different item gives a separate thread.
  Future<Conversation> getOrCreateProductConversation({
    required String sellerName,
    required ChatProduct product,
  });
}
