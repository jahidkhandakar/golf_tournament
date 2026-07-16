import '../../domain/entities/conversation.dart';
import '../../domain/repositories/conversation_repository.dart';

class MockConversationRepository implements ConversationRepository {
  static final List<Conversation> _conversations = [
    Conversation(
      id: 'conv1',
      participantName: 'Marcus Thompson',
      lastMessagePreview: "See you at 7:40 tomorrow!",
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 12)),
      unreadCount: 2,
    ),
    Conversation(
      id: 'conv2',
      participantName: 'Erin Walsh',
      lastMessagePreview: 'That challenge was close, good round.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 0,
    ),
    Conversation(
      id: 'conv3',
      participantName: 'Sam Ortiz',
      lastMessagePreview: 'Still looking for a fourth this weekend?',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 20)),
      unreadCount: 1,
    ),
    Conversation(
      id: 'conv4',
      participantName: 'Priya Kapoor',
      lastMessagePreview: 'Thanks for the invite to the outing!',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
      unreadCount: 0,
    ),
  ];

  @override
  Future<List<Conversation>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _conversations;
  }

  @override
  Future<Conversation> getOrCreateConversationWith(String participantName) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final conversation in _conversations) {
      if (conversation.participantName == participantName) return conversation;
    }
    final conversation = Conversation(
      id: 'conv${DateTime.now().millisecondsSinceEpoch}',
      participantName: participantName,
      lastMessagePreview: 'Say hello!',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
    );
    _conversations.insert(0, conversation);
    return conversation;
  }
}
