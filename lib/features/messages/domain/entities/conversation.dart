import 'package:equatable/equatable.dart';

import 'chat_product.dart';

class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.participantName,
    required this.lastMessagePreview,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.location,
    required this.distanceMiles,
    this.product,
  });

  final String id;
  final String participantName;
  final String lastMessagePreview;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String location;
  final double distanceMiles;

  /// Set when the conversation was started from a marketplace listing.
  final ChatProduct? product;

  @override
  List<Object?> get props =>
      [id, participantName, lastMessagePreview, lastMessageTime, unreadCount, location, distanceMiles, product];
}
