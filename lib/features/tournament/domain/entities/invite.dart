import 'package:equatable/equatable.dart';

enum InviteStatus { pending, accepted, declined }

/// A Club Creator / sub-admin's invitation for a player to join a tournament —
/// the reverse of Request to Play. The invited player accepts (which registers
/// them, bypassing approval) or declines.
class Invite extends Equatable {
  const Invite({
    required this.id,
    required this.tournamentId,
    required this.clubName,
    required this.playerName,
    required this.status,
    required this.invitedAt,
  });

  final String id;
  final String tournamentId;
  final String clubName;

  /// The invited player.
  final String playerName;
  final InviteStatus status;
  final DateTime invitedAt;

  Invite copyWith({InviteStatus? status}) => Invite(
        id: id,
        tournamentId: tournamentId,
        clubName: clubName,
        playerName: playerName,
        status: status ?? this.status,
        invitedAt: invitedAt,
      );

  @override
  List<Object?> get props => [id, tournamentId, clubName, playerName, status, invitedAt];
}
