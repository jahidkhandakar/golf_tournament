import 'package:get_it/get_it.dart';

import '../play/play_controller.dart';
import 'club_role.dart';
import 'feature.dart';

/// Single source of truth for gating.
///
/// [can] handles app-wide feature/plan gating (stubbed to allow everything for
/// now). The club-role methods gate per-club admin actions (tee sheet, scorecard,
/// approvals) against the user's [ClubRole] in that club — every admin-only
/// screen should check these before rendering/executing.
class PermissionService {
  bool can(Feature feature) {
    return true;
  }

  ClubRole roleInClub(String clubName) => GetIt.instance<PlayController>().roleIn(clubName);

  /// Build/edit the tee sheet for a tournament run by [clubName] (§4, §5).
  bool canManageTeeSheet(String clubName) => roleInClub(clubName).canEditTeeSheet;

  /// Enter scorecard results for [clubName]'s tournaments (§4, §6).
  bool canEnterScorecard(String clubName) => roleInClub(clubName).canEnterScorecard;

  /// Approve non-member Request-to-Play into [clubName]'s tournaments (§1, §4).
  bool canApproveRequests(String clubName) => roleInClub(clubName).canApproveRequests;

  /// Approve in-tournament challenges for [clubName] (§3, §4).
  bool canApproveChallenges(String clubName) => roleInClub(clubName).canApproveChallenges;
}
