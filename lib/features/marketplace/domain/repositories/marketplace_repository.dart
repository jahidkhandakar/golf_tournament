import '../entities/marketplace_listing.dart';

abstract class MarketplaceRepository {
  Future<List<MarketplaceListing>> getListings();

  /// The listing featured in Home's sponsored banner, if any.
  Future<MarketplaceListing?> getSponsoredListing();
}
