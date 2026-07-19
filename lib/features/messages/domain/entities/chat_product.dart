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
  });

  final String title;

  /// Display string, e.g. "\$58".
  final String price;
  final String sellerName;

  /// Stand-in for the listing photo.
  final IconData icon;

  @override
  List<Object?> get props => [title, price, sellerName, icon];
}
