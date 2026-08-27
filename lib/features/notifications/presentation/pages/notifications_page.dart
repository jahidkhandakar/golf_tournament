import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../widgets/notification_tile.dart';

/// Pushed full-screen from the app bar bell (no bottom nav).
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<AppNotification>> _future = _load();

  NotificationRepository get _repository => GetIt.instance<NotificationRepository>();

  Future<List<AppNotification>> _load() => _repository.getNotifications();

  Future<void> _markRead(AppNotification notification) async {
    if (notification.isRead) return;
    await _repository.markRead(notification.id);
    setState(() {
      _future = _load();
    });
  }

  Future<void> _removeNotification(String id) async {
    await _repository.remove(id);
    setState(() {
      _future = _load();
    });
  }

  Future<void> _clearAll() async {
    await _repository.clearAll();
    setState(() {
      _future = _load();
    });
  }

  Widget _swipeBackground(Alignment alignment) {
    return Container(
      color: AppColors.error,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: const Icon(Icons.delete_outline, color: AppColors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Body only — the shell provides the "Notifications" AppBar for this tab.
    // The "Clear all" button lives in the body (not a nested bottomNavigationBar,
    // which the shell's own bottom nav would obscure).
    return FutureBuilder<List<AppNotification>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final notifications = snapshot.data!;
        if (notifications.isEmpty) {
          return const Center(child: Text('No notifications yet.'));
        }
        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 72),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Dismissible(
                    key: ValueKey(notification.id),
                    direction: DismissDirection.horizontal,
                    background: _swipeBackground(Alignment.centerLeft),
                    secondaryBackground: _swipeBackground(Alignment.centerRight),
                    onDismissed: (_) => _removeNotification(notification.id),
                    child: NotificationTile(
                      notification: notification,
                      onTap: () => _markRead(notification),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _clearAll,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: const Text('Clear all'),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
