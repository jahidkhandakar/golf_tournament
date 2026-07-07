import '../entities/marketplace_listing.dart';

abstract class MarketplaceRepository {
  Future<List<MarketplaceListing>> getListings();
}
