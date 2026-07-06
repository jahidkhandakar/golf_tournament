import 'package:equatable/equatable.dart';

class Message extends Equatable {
  const Message({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.timestamp,
    required this.isMine,
  });

  final String id;
  final String conversationId;
  final String text;
  final DateTime timestamp;
  final bool isMine;

  @override
  List<Object?> get props => [id, conversationId, text, timestamp, isMine];
}
