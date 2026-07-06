import 'package:equatable/equatable.dart';

import 'club_member.dart';

/// The current user's home club. A `null` [ClubRepository.getMyClub] result
/// means the user hasn't joined (or started) a club yet.
class Club extends Equatable {
  const Club({
    required this.id,
    required this.name,
    required this.members,
  });

  final String id;
  final String name;
  final List<ClubMember> members;

  int get memberCount => members.length;

  @override
  List<Object?> get props => [id, name, members];
}
