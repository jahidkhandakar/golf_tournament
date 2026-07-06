import 'package:equatable/equatable.dart';

/// A player's "looking to play" post, browsed on the Looking tab.
class LookingPost extends Equatable {
  const LookingPost({
    required this.id,
    required this.playerName,
    required this.location,
    required this.availableDates,
    required this.preferredFormats,
    required this.note,
  });

  final String id;
  final String playerName;
  final String location;
  final List<String> availableDates;
  final List<String> preferredFormats;
  final String note;

  @override
  List<Object?> get props => [
        id,
        playerName,
        location,
        availableDates,
        preferredFormats,
        note,
      ];
}
