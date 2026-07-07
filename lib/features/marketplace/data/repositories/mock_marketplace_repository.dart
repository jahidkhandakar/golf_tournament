import 'package:flutter/material.dart';

import '../../domain/entities/marketplace_listing.dart';
import '../../domain/repositories/marketplace_repository.dart';

/// Hardcoded stand-in for a real API-backed repository. View-only — GGW
/// Connect never handles checkout or payment for these listings.
class MockMarketplaceRepository implements MarketplaceRepository {
  static final List<MarketplaceListing> _listings = [
    MarketplaceListing(
      id: 'mkt1',
      title: 'Titleist Pro V1 (2 dozen)',
      price: 58,
      sellerName: 'Marcus Thompson',
      location: 'Austin, TX',
      postedDate: DateTime.now().subtract(const Duration(hours: 5)),
      description: 'Two dozen, brand new, never hit. Bought too many for a tournament.',
      icon: Icons.sports_golf,
    ),
    MarketplaceListing(
      id: 'mkt2',
      title: 'Left-handed driver, 10.5°',
      price: 110,
      sellerName: 'Dana Reyes',
      location: 'Round Rock, TX',
      postedDate: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Barely used, regular flex shaft. Upgraded to a new model.',
      icon: Icons.golf_course,
    ),
    MarketplaceListing(
      id: 'mkt3',
      title: 'Push cart, 3-wheel',
      price: 65,
      sellerName: 'Priya Kapoor',
      location: 'Cedar Park, TX',
      postedDate: DateTime.now().subtract(const Duration(days: 2)),
      description: 'Foldable push cart, umbrella holder included. Great condition.',
      icon: Icons.shopping_cart_outlined,
    ),
    MarketplaceListing(
      id: 'mkt4',
      title: 'Golf bag, Sun Mountain',
      price: 85,
      sellerName: 'Sam Ortiz',
      location: 'Austin, TX',
      postedDate: DateTime.now().subtract(const Duration(days: 3)),
      description: '14-way top, stand bag, a few scuffs but structurally solid.',
      icon: Icons.backpack_outlined,
    ),
    MarketplaceListing(
      id: 'mkt5',
      title: 'Rangefinder with slope',
      price: 140,
      sellerName: 'Erin Walsh',
      location: 'Dallas, TX',
      postedDate: DateTime.now().subtract(const Duration(days: 4)),
      description: 'Includes case and extra battery. Accurate to 1 yard.',
      icon: Icons.center_focus_strong_outlined,
    ),
    MarketplaceListing(
      id: 'mkt6',
      title: 'Golf shoes, size 10.5',
      price: 40,
      sellerName: 'Jordan Blake',
      location: 'Round Rock, TX',
      postedDate: DateTime.now().subtract(const Duration(days: 6)),
      description: 'Worn twice, waterproof, spikeless. Just the wrong size for me.',
      icon: Icons.hiking_outlined,
    ),
  ];

  @override
  Future<List<MarketplaceListing>> getListings() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _listings;
  }
}
