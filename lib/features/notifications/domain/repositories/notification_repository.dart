import '../entities/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications();

  /// Add a notification to the top of the current user's inbox.
  Future<void> push(AppNotification notification);
  Future<void> markRead(String id);
  Future<void> remove(String id);
  Future<void> clearAll();
}
