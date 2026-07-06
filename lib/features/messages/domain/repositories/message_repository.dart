import '../entities/message.dart';

abstract class MessageRepository {
  Future<List<Message>> getMessages(String conversationId);

  /// Messaging is always free — no permission check on this path.
  Future<void> sendMessage(String conversationId, String text);
}
