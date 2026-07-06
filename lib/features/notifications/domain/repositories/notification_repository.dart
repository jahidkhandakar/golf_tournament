import '../entities/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications();
  Future<void> markRead(String id);
  Future<void> remove(String id);
  Future<void> clearAll();
}
