import '../entities/conversation.dart';

abstract class ConversationRepository {
  Future<List<Conversation>> getConversations();

  /// Returns the existing conversation with this participant, or starts a
  /// new one — used by "Message" buttons on golfer profiles.
  Future<Conversation> getOrCreateConversationWith(String participantName);
}
