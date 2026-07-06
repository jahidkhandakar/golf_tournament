import 'package:equatable/equatable.dart';

import '../../../../core/user/user_tier.dart';

/// The current golfer's identity + tier — shown in both the drawer header
/// and the Profile screen header, so both read from the same source.
class UserProfile extends Equatable {
  const UserProfile({
    required this.name,
    required this.tier,
    required this.handicap,
  });

  final String name;
  final UserTier tier;
  final double handicap;

  @override
  List<Object?> get props => [name, tier, handicap];
}
