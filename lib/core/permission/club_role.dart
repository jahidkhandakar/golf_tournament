/// A user's role within a specific club. Roles are per-club — the same user can
/// be the Creator of one club, a Member of another, and a Non-Member elsewhere.
/// Mirrors the Permissions table in the GGW Connect build spec (§4).
enum ClubRole { creator, subAdmin, member, nonMember }

/// The maximum number of sub-admins a single club may have (§4). Enforced by the
/// (future) sub-admin management screen, where the Club Creator appoints them
/// from the club's members.
const int maxSubAdminsPerClub = 3;

extension ClubRoleX on ClubRole {
  /// Creator or sub-admin — the two roles that manage a club's tournaments
  /// (tee sheet, scorecard, request/challenge approval).
  bool get isStaff => this == ClubRole.creator || this == ClubRole.subAdmin;

  bool get canEditTeeSheet => isStaff;
  bool get canEnterScorecard => isStaff;
  bool get canApproveRequests => isStaff;
  bool get canApproveChallenges => isStaff;

  /// Only the Club Creator can appoint or remove sub-admins.
  bool get canAssignSubAdmins => this == ClubRole.creator;

  /// Members (and staff, who are members too) register straight into a
  /// tournament; non-members must Request to Play and wait for approval.
  bool get canRegisterDirectly => this != ClubRole.nonMember;
  bool get canSubmitPairingPreference => this != ClubRole.nonMember;
  bool get mustRequestToPlay => this == ClubRole.nonMember;

  String get label {
    switch (this) {
      case ClubRole.creator:
        return 'Club Creator';
      case ClubRole.subAdmin:
        return 'Sub-Admin';
      case ClubRole.member:
        return 'Member';
      case ClubRole.nonMember:
        return 'Non-Member';
    }
  }
}
