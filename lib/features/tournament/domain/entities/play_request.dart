import 'package:equatable/equatable.dart';

enum RegistrationStatus { pending, approved, rejected }

/// A non-member's Request to Play for a tournament, awaiting a Club Creator /
/// sub-admin decision (§1). Members skip this and register directly.
class PlayRequest extends Equatable {
  const PlayRequest({
    required this.id,
    required this.tournamentId,
    required this.playerName,
    required this.homeClub,
    required this.status,
    required this.requestedAt,
  });

  final String id;
  final String tournamentId;
  final String playerName;
  final String homeClub;
  final RegistrationStatus status;
  final DateTime requestedAt;

  PlayRequest copyWith({RegistrationStatus? status}) => PlayRequest(
        id: id,
        tournamentId: tournamentId,
        playerName: playerName,
        homeClub: homeClub,
        status: status ?? this.status,
        requestedAt: requestedAt,
      );

  @override
  List<Object?> get props => [id, tournamentId, playerName, homeClub, status, requestedAt];
}
