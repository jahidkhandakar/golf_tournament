import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// A platform-wide marketplace listing — distinct from a club's own
/// Marketplace tab, which only shows listings within that club.
class MarketplaceListing extends Equatable {
  const MarketplaceListing({
    required this.id,
    required this.title,
    required this.price,
    required this.sellerName,
    required this.location,
    required this.postedDate,
    required this.description,
    required this.icon,
    required this.imageKey,
    this.isSponsored = false,
  });

  final String id;
  final String title;
  final double price;
  final String sellerName;
  final String location;
  final DateTime postedDate;
  final String description;

  /// Fallback icon if the photo can't load.
  final IconData icon;

  /// Matches assets/pics/equipments/<imageKey>.jpg (see AppImages.equipment).
  final String imageKey;

  /// Whether this is the listing featured in Home's sponsored banner.
  final bool isSponsored;

  @override
  List<Object?> get props =>
      [id, title, price, sellerName, location, postedDate, description, icon, imageKey, isSponsored];
}
