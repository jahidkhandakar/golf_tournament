import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/ggw_app_bar.dart';
import '../../../messages/domain/repositories/conversation_repository.dart';
import '../../../notifications/domain/repositories/notification_repository.dart';
import 'app_drawer.dart';

class _TabConfig {
  const _TabConfig(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _tabs = [
  _TabConfig('Home', Icons.home_outlined, Icons.home),
  _TabConfig('My Club', Icons.flag_outlined, Icons.flag),
  _TabConfig('Top 50', Icons.emoji_events_outlined, Icons.emoji_events),
  _TabConfig('Users', Icons.people_outline, Icons.people),
  _TabConfig('Notifications', Icons.notifications_none, Icons.notifications),
];

/// Shell wrapping the logged-in experience: a shared AppBar + Drawer, the
/// 5-tab bottom navigation, and the current tab's content.
///
/// [navigationShell] is provided by go_router's `StatefulShellRoute
/// .indexedStack`, which keeps each tab's navigator (and therefore its
/// scroll/form state) alive under the hood — the "IndexedStack" behavior is
/// built into that route type.
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // GgwAppBar is a separate widget passed into Scaffold(appBar: ...), so the
  // context available where it's built is the context above the Scaffold —
  // `Scaffold.of(context)` from there can't find it. A GlobalKey sidesteps
  // that entirely.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final Future<int> _unreadMessagesFuture = _countUnreadMessages();
  late Future<int> _unreadNotificationsFuture = _countUnreadNotifications();

  Future<int> _countUnreadMessages() async {
    final conversations = await GetIt.instance<ConversationRepository>().getConversations();
    return conversations.fold<int>(0, (sum, c) => sum + c.unreadCount);
  }

  Future<int> _countUnreadNotifications() async {
    final notifications = await GetIt.instance<NotificationRepository>().getNotifications();
    return notifications.where((n) => !n.isRead).length;
  }


  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isHome = widget.navigationShell.currentIndex == 0;

    if (isHome) {
      return GgwAppBar(
        leadingActions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push(AppRoutes.search),
          ),
        ],
        titleWidget: Text(
          'GGW Connect',
          style: AppTextStyles.heading3(AppColors.black),
        ),
        trailingActions: [
          IconButton(
            icon: const Icon(Icons.location_on_outlined),
            onPressed: () => context.push(AppRoutes.location),
          ),
          IconButton(
            tooltip: 'Toggle light/dark mode',
            icon: ValueListenableBuilder<ThemeMode>(
              valueListenable: GetIt.instance<ThemeController>().themeMode,
              builder: (context, mode, _) {
                final isDark = mode == ThemeMode.dark ||
                    (mode == ThemeMode.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark);
                return Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined);
              },
            ),
            onPressed: () =>
                GetIt.instance<ThemeController>().toggle(MediaQuery.platformBrightnessOf(context)),
          ),
          IconButton(
            tooltip: 'Messages',
            icon: FutureBuilder<int>(
              future: _unreadMessagesFuture,
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  backgroundColor: AppColors.white,
                  textColor: AppColors.error,
                  largeSize: 20,
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  child: const Icon(Icons.chat_bubble_outline),
                );
              },
            ),
            onPressed: () => context.push(AppRoutes.messages),
          ),
        ],
      );
    }

    return GgwAppBar(
      leadingActions: [
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ],
      titleWidget: Text(_tabs[widget.navigationShell.currentIndex].label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(context),
      drawer: const AppDrawer(),
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
          if (index == 4) {
            setState(() => _unreadNotificationsFuture = _countUnreadNotifications());
          }
        },
        destinations: [
          for (var i = 0; i < _tabs.length; i++)
            NavigationDestination(
              icon: i == 4
                  ? FutureBuilder<int>(
                      future: _unreadNotificationsFuture,
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        return Badge(
                          isLabelVisible: count > 0,
                          label: Text('$count'),
                          backgroundColor: AppColors.white,
                          textColor: AppColors.error,
                          largeSize: 20,
                          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          child: Icon(_tabs[i].icon),
                        );
                      },
                    )
                  : Icon(_tabs[i].icon),
              selectedIcon: Icon(_tabs[i].selectedIcon),
              label: _tabs[i].label,
            ),
        ],
      ),
    );
  }
}
