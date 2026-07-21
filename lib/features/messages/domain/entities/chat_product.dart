import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// The marketplace item a conversation is about. Pinned at the top of the
/// chat so both people remember which listing they're negotiating — the
/// deal itself happens in person (no in-app payments).
class ChatProduct extends Equatable {
  const ChatProduct({
    required this.title,
    required this.price,
    required this.sellerName,
    required this.icon,
    required this.imageKey,
  });

  final String title;

  /// Display string, e.g. "\$58".
  final String price;
  final String sellerName;

  /// Fallback icon if the photo can't load.
  final IconData icon;

  /// Matches assets/pics/equipments/<imageKey>.jpg.
  final String imageKey;

  @override
  List<Object?> get props => [title, price, sellerName, icon, imageKey];
}
