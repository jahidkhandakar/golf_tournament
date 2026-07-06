import 'package:equatable/equatable.dart';

class ClubMember extends Equatable {
  const ClubMember({
    required this.id,
    required this.name,
    required this.handicap,
    this.isAdmin = false,
  });

  final String id;
  final String name;
  final double handicap;
  final bool isAdmin;

  @override
  List<Object?> get props => [id, name, handicap, isAdmin];
}
