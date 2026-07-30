import 'package:equatable/equatable.dart';

/// One player's score on the scorecard. [gross] is the total; [holes] is the
/// per-hole breakdown when the admin enters by-hole (its sum is the gross).
class PlayerScore extends Equatable {
  const PlayerScore({required this.playerName, this.gross, this.holes});

  final String playerName;
  final int? gross;
  final List<int>? holes;

  bool get hasScore => gross != null;

  @override
  List<Object?> get props => [playerName, gross, holes];
}
