/// Named route paths for every screen in the app.
class AppRoutes {
  AppRoutes._();

  // Pre-login flow
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String locationPermission = '/location-permission';

  // Bottom-nav tabs (branches of the main shell)
  static const String home = '/home';
  static const String club = '/club';
  static const String top50 = '/top50';
  static const String messages = '/messages';
  static const String profile = '/profile';

  // Pushed on top of the shell (no bottom nav)
  static const String notifications = '/notifications';
  static const String location = '/location';
  static const String search = '/search';
  static const String myClubs = '/my-clubs';
  static const String subscriptionPayment = '/subscription-payment';
  static const String settings = '/settings';
  static const String helpSupport = '/help-support';
  static const String aboutLegal = '/about-legal';
  static const String termsOfService = '/about-legal/terms';
  static const String privacyPolicy = '/about-legal/privacy';
  static const String createClub = '/create-club';
  static const String marketplace = '/marketplace';
  static const String createLookingPost = '/looking-to-play/create';
  static const String myProfile = '/my-profile';

  static String chatDetail(String conversationId) => '/messages/chat/$conversationId';
  static String marketplaceListingDetail(String id) => '/marketplace/$id';
  static String golferProfile(String id) => '/golfers/$id';
}
