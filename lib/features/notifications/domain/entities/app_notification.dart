import 'package:equatable/equatable.dart';

enum NotificationType { requestAccepted, teeTimePosted, teeTimeChanged, newChallenge, clubInvite, newMessage }

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.type,
    required this.text,
    required this.timestamp,
    required this.isRead,
  });

  final String id;
  final NotificationType type;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      text: text,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [id, type, text, timestamp, isRead];
}
