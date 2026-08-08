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
  static const String createTournament = '/create-tournament';
  static const String tournaments = '/tournaments';
  static const String marketplace = '/marketplace';
  static const String createLookingPost = '/looking-to-play/create';
  static const String myProfile = '/my-profile';
  static const String teeSheet = '/tee-sheet';
  static const String teeSheetBuilder = '/tee-sheet/builder';
  static const String nearbyGolfers = '/golfers';
  static const String kpLive = '/tournaments/kp-live';
  static const String privateMembers = '/club/private-members';
  static const String joinPrivateClub = '/join-private-club';
  static const String indoor = '/indoor';
  static const String simBoard = '/indoor/sim-board';

  static String chatDetail(String conversationId) => '/messages/chat/$conversationId';
  static String marketplaceListingDetail(String id) => '/marketplace/$id';
  static String golferProfile(String id) => '/golfers/$id';
  static String challengePlayer(String playerName) => '/top50/challenge/$playerName';
  static String tournamentDetail(String id) => '/tournaments/$id';
  static String challengeApprovals(String id) => '/tournaments/$id/challenges';
  static String invitePlayers(String id) => '/tournaments/$id/invite';
  static String teeSheetBuilderFor(String id) => '/tournaments/$id/tee-sheet';
  static String scorecardEntry(String id) => '/tournaments/$id/scorecard';
}
