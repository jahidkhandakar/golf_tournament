import 'package:go_router/go_router.dart';

import '../../features/about_legal/presentation/pages/about_legal_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/club/presentation/pages/club_page.dart';
import '../../features/golfers/domain/entities/nearby_golfer.dart';
import '../../features/golfers/presentation/pages/golfer_profile_page.dart';
import '../../features/golfers/presentation/pages/nearby_golfers_page.dart';
import '../../features/help_support/presentation/pages/help_support_page.dart';
import '../../features/home/presentation/pages/create_looking_post_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/search_page.dart';
import '../../features/location/presentation/pages/location_page.dart';
import '../../features/location/presentation/pages/location_permission_page.dart';
import '../../features/marketplace/domain/entities/marketplace_listing.dart';
import '../../features/marketplace/presentation/pages/listing_detail_page.dart';
import '../../features/marketplace/presentation/pages/marketplace_page.dart';
import '../../features/messages/domain/entities/conversation.dart';
import '../../features/messages/presentation/pages/chat_detail_page.dart';
import '../../features/messages/presentation/pages/messages_page.dart';
import '../../features/my_clubs/presentation/pages/my_clubs_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/shell/presentation/widgets/main_shell.dart';
import '../../features/subscription/presentation/pages/subscription_page.dart';
import '../../features/top50/presentation/pages/top50_page.dart';
import '../widgets/legal_text_page.dart';
import '../widgets/placeholder_scaffold.dart';
import 'app_routes.dart';

const _termsPlaceholder =
    'These are placeholder Terms & Conditions for GGW Connect. Real terms will be provided before launch. '
    'By using this app, you agree to treat other golfers with respect, keep your account information '
    'accurate, and use the platform for its intended purpose of organizing and joining golf rounds.';

const _privacyPlaceholder =
    'This is a placeholder Privacy Policy for GGW Connect. Real policy details will be provided before '
    'launch. Location, profile and activity data are used only to power features like nearby clubs, '
    'outings and player matchmaking, and are never sold to third parties.';

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
                builder: (context, state) => const NearbyGolfersPage(),
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
        path: AppRoutes.search,
        name: 'search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/messages/chat/:conversationId',
        name: 'chatDetail',
        builder: (context, state) => ChatDetailPage(conversation: state.extra as Conversation),
      ),
      GoRoute(
        path: AppRoutes.myClubs,
        name: 'myClubs',
        builder: (context, state) => const MyClubsPage(),
      ),
      GoRoute(
        path: AppRoutes.subscriptionPayment,
        name: 'subscriptionPayment',
        builder: (context, state) => const SubscriptionPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.helpSupport,
        name: 'helpSupport',
        builder: (context, state) => const HelpSupportPage(),
      ),
      GoRoute(
        path: AppRoutes.aboutLegal,
        name: 'aboutLegal',
        builder: (context, state) => const AboutLegalPage(),
      ),
      GoRoute(
        path: AppRoutes.termsOfService,
        name: 'termsOfService',
        builder: (context, state) => const LegalTextPage(title: 'Terms & Conditions', body: _termsPlaceholder),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        name: 'privacyPolicy',
        builder: (context, state) => const LegalTextPage(title: 'Privacy Policy', body: _privacyPlaceholder),
      ),
      GoRoute(
        path: AppRoutes.createClub,
        name: 'createClub',
        builder: (context, state) => const PlaceholderScaffold(title: 'Start a Club'),
      ),
      GoRoute(
        path: AppRoutes.marketplace,
        name: 'marketplace',
        builder: (context, state) => const MarketplacePage(),
      ),
      GoRoute(
        path: '/marketplace/:id',
        name: 'marketplaceListingDetail',
        builder: (context, state) => ListingDetailPage(listing: state.extra as MarketplaceListing),
      ),
      GoRoute(
        path: AppRoutes.createLookingPost,
        name: 'createLookingPost',
        builder: (context, state) => const CreateLookingPostPage(),
      ),
      GoRoute(
        path: AppRoutes.myProfile,
        name: 'myProfile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/golfers/:id',
        name: 'golferProfile',
        builder: (context, state) => GolferProfilePage(golfer: state.extra as NearbyGolfer),
      ),
    ],
  );
}
