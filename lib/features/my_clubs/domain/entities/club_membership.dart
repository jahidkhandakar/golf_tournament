import 'package:equatable/equatable.dart';

enum ClubRole { member, admin }

/// One club the current user belongs to. Distinct from [Club] (the Club
/// tab's single "home club" concept) — a golfer can belong to more than one.
class ClubMembership extends Equatable {
  const ClubMembership({
    required this.id,
    required this.clubName,
    required this.location,
    required this.memberCount,
    required this.role,
    required this.isHomeClub,
  });

  final String id;
  final String clubName;
  final String location;
  final int memberCount;
  final ClubRole role;

  /// Whether this is the club shown on the Club tab.
  final bool isHomeClub;

  @override
  List<Object?> get props => [id, clubName, location, memberCount, role, isHomeClub];
}
