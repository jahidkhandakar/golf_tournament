import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

class MockNotificationRepository implements NotificationRepository {
  List<AppNotification> _notifications = [
    AppNotification(
      id: 'n1',
      type: NotificationType.requestAccepted,
      text: 'Riverbend Golf Club accepted your request to play.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      isRead: false,
    ),
    AppNotification(
      id: 'n2',
      type: NotificationType.teeTimePosted,
      text: 'A new tee sheet was posted for Saturday\'s gaggle.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    AppNotification(
      id: 'n3',
      type: NotificationType.newChallenge,
      text: 'Jordan Blake challenged you to a match.',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      isRead: false,
    ),
    AppNotification(
      id: 'n4',
      type: NotificationType.clubInvite,
      text: 'You were invited to join Oakmont Hills.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  @override
  Future<List<AppNotification>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_notifications);
  }

  @override
  Future<void> markRead(String id) async {
    _notifications = [
      for (final n in _notifications)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  @override
  Future<void> remove(String id) async {
    _notifications = [for (final n in _notifications) if (n.id != id) n];
  }

  @override
  Future<void> clearAll() async {
    _notifications = [];
  }
}
