import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/assets/app_images.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../marketplace/domain/entities/equipment_catalog.dart';
import '../../../marketplace/domain/entities/marketplace_listing.dart';
import '../../domain/entities/club_member.dart';

/// A club's own marketplace. Listings are built from the club's members so
/// switching clubs shows a different set of sellers and items. Tapping a tile
/// opens the shared marketplace detail page (with "Message Seller").
class MarketplaceTab extends StatefulWidget {
  const MarketplaceTab({
    super.key,
    required this.clubName,
    required this.clubLocation,
    required this.members,
  });

  final String clubName;
  final String clubLocation;
  final List<ClubMember> members;

  @override
  State<MarketplaceTab> createState() => _MarketplaceTabState();
}

class _MarketplaceTabState extends State<MarketplaceTab> {
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

  List<MarketplaceListing> _listingsForClub() {
    // Offset the catalogue by the club name so two clubs with similar rosters
    // still show different items.
    final offset = widget.clubName.hashCode.abs();
    return List.generate(widget.members.length, (i) {
      final item = equipmentCatalog[(i + offset) % equipmentCatalog.length];
      final member = widget.members[i];
      return MarketplaceListing(
        id: 'club-${widget.clubName}-$i',
        title: item.title,
        price: item.price,
        sellerName: member.name,
        location: widget.clubLocation,
        postedDate: DateTime.now().subtract(Duration(days: i + 1)),
        description: '${item.title} listed by ${member.name} at ${widget.clubName}. '
            'Message to arrange a meetup — GGW Connect deals happen in person.',
        icon: item.icon,
        imageKey: item.imageKey,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final query = _queryController.text.trim().toLowerCase();
    final all = _listingsForClub();
    final listings = query.isEmpty
        ? all
        : all
            .where((l) =>
                l.title.toLowerCase().contains(query) || l.sellerName.toLowerCase().contains(query))
            .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: _searching
                    ? TextField(
                        controller: _queryController,
                        autofocus: true,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Search this club\'s marketplace...',
                          isDense: true,
                        ),
                      )
                    : Text('${widget.clubName} Marketplace', style: AppTextStyles.heading3(primaryText)),
              ),
              IconButton(
                icon: Icon(_searching ? Icons.close : Icons.search),
                onPressed: _toggleSearch,
              ),
            ],
          ),
        ),
        Expanded(
          child: listings.isEmpty
              ? Center(child: Text('No listings found', style: AppTextStyles.body(secondaryText)))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    return Card(
                      child: InkWell(
                        onTap: () =>
                            context.push(AppRoutes.marketplaceListingDetail(listing.id), extra: listing),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    AppImages.equipment(listing.imageKey),
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    cacheWidth: 400,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Center(child: Icon(listing.icon, size: 40, color: AppColors.gold)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(listing.title, style: AppTextStyles.bodyBold(primaryText), maxLines: 2),
                              const SizedBox(height: 4),
                              Text('\$${listing.price.toStringAsFixed(0)}',
                                  style: AppTextStyles.heading3(AppColors.goldDark)),
                              Text('by ${listing.sellerName}', style: AppTextStyles.caption(secondaryText)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
