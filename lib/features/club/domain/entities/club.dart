import 'package:equatable/equatable.dart';

import 'club_member.dart';

/// A golf club — both the ones the user belongs to (shown on the Club tab
/// detail view) and discoverable ones (shown in My Clubs). Membership isn't
/// stored here; it's tracked by name in PlayController.joinedClubs so the
/// Club tab, My Clubs, and the Top 50 challenge flow all share one source.
class Club extends Equatable {
  const Club({
    required this.id,
    required this.name,
    required this.location,
    required this.members,
    this.isPrivate = false,
  });

  final String id;
  final String name;
  final String location;
  final List<ClubMember> members;

  /// Private clubs are invisible in discovery, search, and all public feeds.
  /// Invite is by creator-issued access code only. Events never feed the zone
  /// Top 50. Conversion is one way: private can go public, never back.
  final bool isPrivate;

  int get memberCount => members.length;

  Club withMembers(List<ClubMember> members) =>
      Club(id: id, name: name, location: location, members: members, isPrivate: isPrivate);

  @override
  List<Object?> get props => [id, name, location, members, isPrivate];
}
