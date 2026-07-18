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
  });

  final String id;
  final String name;
  final String location;
  final List<ClubMember> members;

  int get memberCount => members.length;

  @override
  List<Object?> get props => [id, name, location, members];
}
