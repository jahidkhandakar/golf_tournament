import '../../domain/entities/equipment_catalog.dart';
import '../../domain/entities/marketplace_listing.dart';
import '../../domain/repositories/marketplace_repository.dart';

/// Hardcoded stand-in for a real API-backed repository. Lists one item per
/// catalogue entry (so every equipment photo is used exactly once). View-only
/// — GGW Connect never handles checkout or payment.
class MockMarketplaceRepository implements MarketplaceRepository {
  static const List<String> _sellers = [
    'Marcus Thompson',
    'Dana Reyes',
    'Priya Kapoor',
    'Sam Ortiz',
    'Erin Walsh',
    'Jordan Blake',
    'Casey Nguyen',
    'Devon Lee',
  ];
  static const List<String> _locations = ['Austin, TX', 'Round Rock, TX', 'Cedar Park, TX', 'Dallas, TX'];

  static final List<MarketplaceListing> _listings = _build();

  static List<MarketplaceListing> _build() {
    final now = DateTime.now();
    return [
      for (var i = 0; i < equipmentCatalog.length; i++)
        MarketplaceListing(
          id: 'mkt${i + 1}',
          title: equipmentCatalog[i].title,
          price: equipmentCatalog[i].price,
          sellerName: _sellers[i % _sellers.length],
          location: _locations[i % _locations.length],
          postedDate: now.subtract(Duration(hours: (i + 1) * 7)),
          description: '${equipmentCatalog[i].title} in great condition. '
              'Message to arrange a meetup — GGW Connect deals happen in person.',
          icon: equipmentCatalog[i].icon,
          imageKey: equipmentCatalog[i].imageKey,
          isSponsored: i == 0,
        ),
    ];
  }

  @override
  Future<List<MarketplaceListing>> getListings() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _listings;
  }

  @override
  Future<MarketplaceListing?> getSponsoredListing() async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (final listing in _listings) {
      if (listing.isSponsored) return listing;
    }
    return null;
  }
}
