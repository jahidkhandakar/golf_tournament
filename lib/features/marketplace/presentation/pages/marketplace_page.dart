import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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

  bool _searching = false;
  final _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) _queryController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _queryController.text.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _queryController,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                style: AppTextStyles.body(AppColors.black),
                decoration: const InputDecoration(
                  hintText: 'Search the marketplace...',
                  border: InputBorder.none,
                ),
              )
            : const Text('Marketplace'),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: FutureBuilder<List<MarketplaceListing>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final listings = snapshot.data!
              .where((listing) =>
                  query.isEmpty ||
                  listing.title.toLowerCase().contains(query) ||
                  listing.sellerName.toLowerCase().contains(query) ||
                  listing.location.toLowerCase().contains(query))
              .toList();

          if (listings.isEmpty) {
            return const Center(child: Text('No listings found'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
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
