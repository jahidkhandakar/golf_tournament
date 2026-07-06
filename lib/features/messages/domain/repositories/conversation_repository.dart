import '../entities/conversation.dart';

abstract class ConversationRepository {
  Future<List<Conversation>> getConversations();
}
