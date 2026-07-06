import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

import '../../features/club/data/repositories/mock_club_repository.dart';
import '../../features/club/domain/repositories/club_repository.dart';
import '../../features/home/data/repositories/mock_gaggle_repository.dart';
import '../../features/home/data/repositories/mock_looking_repository.dart';
import '../../features/home/data/repositories/mock_outing_repository.dart';
import '../../features/home/domain/repositories/gaggle_repository.dart';
import '../../features/home/domain/repositories/looking_repository.dart';
import '../../features/home/domain/repositories/outing_repository.dart';
import '../../features/messages/data/repositories/mock_conversation_repository.dart';
import '../../features/messages/data/repositories/mock_message_repository.dart';
import '../../features/messages/domain/repositories/conversation_repository.dart';
import '../../features/messages/domain/repositories/message_repository.dart';
import '../../features/notifications/data/repositories/mock_notification_repository.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/profile/data/repositories/mock_challenge_repository.dart';
import '../../features/profile/data/repositories/mock_round_repository.dart';
import '../../features/profile/data/repositories/mock_user_profile_repository.dart';
import '../../features/profile/domain/repositories/challenge_repository.dart';
import '../../features/profile/domain/repositories/round_repository.dart';
import '../../features/profile/domain/repositories/user_profile_repository.dart';
import '../../features/top50/data/repositories/mock_leaderboard_repository.dart';
import '../../features/top50/domain/repositories/leaderboard_repository.dart';
import '../location/location_state.dart';
import '../network/network_info.dart';
import '../permission/permission_service.dart';
import '../theme/theme_controller.dart';

final GetIt sl = GetIt.instance;

/// Registers app-wide singletons. Call once from `main()` before `runApp`.
/// Feature modules will register their own datasources/repositories/use
/// cases here as they're built out.
Future<void> setupLocator() async {
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<PermissionService>(() => PermissionService());
  sl.registerLazySingleton<LocationState>(() => LocationState());
  sl.registerLazySingleton<ThemeController>(() => ThemeController());

  // Every repository below is a mock backed by hardcoded data for now;
  // swap for a real API-backed implementation behind the same interface
  // when the backend is ready.
  sl.registerLazySingleton<GaggleRepository>(() => MockGaggleRepository());
  sl.registerLazySingleton<OutingRepository>(() => MockOutingRepository());
  sl.registerLazySingleton<LookingRepository>(() => MockLookingRepository());
  sl.registerLazySingleton<ClubRepository>(() => MockClubRepository());
  sl.registerLazySingleton<LeaderboardRepository>(() => MockLeaderboardRepository());
  sl.registerLazySingleton<RoundRepository>(() => MockRoundRepository());
  sl.registerLazySingleton<ChallengeRepository>(() => MockChallengeRepository());
  sl.registerLazySingleton<UserProfileRepository>(() => MockUserProfileRepository());
  sl.registerLazySingleton<ConversationRepository>(() => MockConversationRepository());
  sl.registerLazySingleton<MessageRepository>(() => MockMessageRepository());
  sl.registerLazySingleton<NotificationRepository>(() => MockNotificationRepository());
}
