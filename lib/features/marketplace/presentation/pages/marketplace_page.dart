import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../domain/entities/marketplace_listing.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../widgets/listing_card.dart';

/// Platform-wide marketplace, reached from the drawer — separate from a
/// club's own Marketplace tab, which only shows that club's listings.
/// View-only: GGW Connect never handles checkout or payment.
class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  late final Future<List<MarketplaceListing>> _future =
      GetIt.instance<MarketplaceRepository>().getListings();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace')),
      body: FutureBuilder<List<MarketplaceListing>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final listings = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              return ListingCard(
                listing: listing,
                onTap: () => context.push(AppRoutes.marketplaceListingDetail(listing.id), extra: listing),
              );
            },
          );
        },
      ),
    );
  }
}
