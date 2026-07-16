import '../../domain/entities/message.dart';
import '../../domain/repositories/message_repository.dart';

/// Hardcoded stand-in for a real API-backed repository. Sent messages are
/// appended to the in-memory list so the chat screen feels alive within a
/// session — they're not persisted anywhere real.
class MockMessageRepository implements MessageRepository {
  int _nextId = 100;

  final Map<String, List<Message>> _messagesByConversation = {
    'conv1': [
      Message(
        id: 'm1',
        conversationId: 'conv1',
        text: 'Hey, still on for the club round tomorrow?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
        isMine: false,
      ),
      Message(
        id: 'm2',
        conversationId: 'conv1',
        text: "Yep, I'll be there.",
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isMine: true,
      ),
      Message(
        id: 'm3',
        conversationId: 'conv1',
        text: 'See you at 7:40 tomorrow!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        isMine: false,
      ),
    ],
    'conv2': [
      Message(
        id: 'm4',
        conversationId: 'conv2',
        text: 'Good match today.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3, minutes: 5)),
        isMine: true,
      ),
      Message(
        id: 'm5',
        conversationId: 'conv2',
        text: 'That challenge was close, good round.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isMine: false,
      ),
    ],
    'conv3': [
      Message(
        id: 'm6',
        conversationId: 'conv3',
        text: 'Still looking for a fourth this weekend?',
        timestamp: DateTime.now().subtract(const Duration(hours: 20)),
        isMine: false,
      ),
    ],
    'conv4': [
      Message(
        id: 'm7',
        conversationId: 'conv4',
        text: 'Thanks for the invite to the outing!',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isMine: false,
      ),
    ],
  };

  @override
  Future<List<Message>> getMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_messagesByConversation[conversationId] ?? const []);
  }

  @override
  Future<void> sendMessage(String conversationId, String text) async {
    final message = Message(
      id: 'm${_nextId++}',
      conversationId: conversationId,
      text: text,
      timestamp: DateTime.now(),
      isMine: true,
    );
    _messagesByConversation.putIfAbsent(conversationId, () => []).add(message);
  }
}
