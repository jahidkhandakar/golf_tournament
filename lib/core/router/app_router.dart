import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/club/presentation/pages/club_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/location/presentation/pages/location_page.dart';
import '../../features/location/presentation/pages/location_permission_page.dart';
import '../../features/messages/domain/entities/conversation.dart';
import '../../features/messages/presentation/pages/chat_detail_page.dart';
import '../../features/messages/presentation/pages/messages_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/shell/presentation/widgets/main_shell.dart';
import '../../features/top50/presentation/pages/top50_page.dart';
import '../widgets/placeholder_scaffold.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // Pre-login flow: splash -> login/sign up -> location permission -> shell.
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        name: 'signUp',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.locationPermission,
        name: 'locationPermission',
        builder: (context, state) => const LocationPermissionPage(),
      ),

      // Logged-in shell: shared AppBar/Drawer/bottom nav around 5 tabs.
      // StatefulShellRoute.indexedStack keeps each branch's navigator alive
      // (IndexedStack under the hood) so switching tabs preserves state.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.club,
                name: 'club',
                builder: (context, state) => const ClubPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.top50,
                name: 'top50',
                builder: (context, state) => const Top50Page(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.messages,
                name: 'messages',
                builder: (context, state) => const MessagesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // Pushed full-screen on top of the shell (no bottom nav).
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: AppRoutes.location,
        name: 'location',
        builder: (context, state) => const LocationPage(),
      ),
      GoRoute(
        path: '/messages/chat/:conversationId',
        name: 'chatDetail',
        builder: (context, state) => ChatDetailPage(conversation: state.extra as Conversation),
      ),
      GoRoute(
        path: AppRoutes.myClubs,
        name: 'myClubs',
        builder: (context, state) => const PlaceholderScaffold(title: 'My Clubs'),
      ),
      GoRoute(
        path: AppRoutes.subscriptionPayment,
        name: 'subscriptionPayment',
        builder: (context, state) => const PlaceholderScaffold(title: 'Subscription & Payment'),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const PlaceholderScaffold(title: 'Settings'),
      ),
      GoRoute(
        path: AppRoutes.helpSupport,
        name: 'helpSupport',
        builder: (context, state) => const PlaceholderScaffold(title: 'Help & Support'),
      ),
      GoRoute(
        path: AppRoutes.aboutLegal,
        name: 'aboutLegal',
        builder: (context, state) => const PlaceholderScaffold(title: 'About & Legal'),
      ),
      GoRoute(
        path: AppRoutes.createClub,
        name: 'createClub',
        builder: (context, state) => const PlaceholderScaffold(title: 'Start a Club'),
      ),
    ],
  );
}
