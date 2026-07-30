import 'package:equatable/equatable.dart';

class ClubMember extends Equatable {
  const ClubMember({
    required this.id,
    required this.name,
    required this.clubHandicap,
    this.isAdmin = false,
  });

  final String id;
  final String name;

  /// Handicap within this club — clubs set their own rules, so this is the
  /// number the Club Leaderboard ranks by (not the player's global handicap).
  final double clubHandicap;
  final bool isAdmin;

  @override
  List<Object?> get props => [id, name, clubHandicap, isAdmin];
}
