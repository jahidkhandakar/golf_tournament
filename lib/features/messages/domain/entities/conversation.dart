import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.participantName,
    required this.lastMessagePreview,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  final String id;
  final String participantName;
  final String lastMessagePreview;
  final DateTime lastMessageTime;
  final int unreadCount;

  @override
  List<Object?> get props => [id, participantName, lastMessagePreview, lastMessageTime, unreadCount];
}
