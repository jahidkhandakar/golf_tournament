import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../marketplace/domain/entities/marketplace_listing.dart';
import '../../domain/entities/club_member.dart';

/// Pool of items club members list — assigned to members below so each club's
/// marketplace reflects its own roster.
const _itemPool = <({String title, double price, IconData icon})>[
  (title: 'Titleist Pro V1 (dozen)', price: 32, icon: Icons.sports_golf),
  (title: 'Left-handed driver, 10.5°', price: 110, icon: Icons.golf_course),
  (title: 'Push cart, barely used', price: 65, icon: Icons.shopping_cart_outlined),
  (title: 'Golf bag, Sun Mountain', price: 85, icon: Icons.backpack_outlined),
  (title: 'Rangefinder with slope', price: 140, icon: Icons.center_focus_strong_outlined),
  (title: 'Golf shoes, size 10.5', price: 40, icon: Icons.hiking_outlined),
  (title: 'Blade putter', price: 70, icon: Icons.straighten_outlined),
  (title: 'Glove 3-pack', price: 25, icon: Icons.back_hand_outlined),
];

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
    // Offset the item pool by the club name so two clubs with similar rosters
    // still show different items.
    final offset = widget.clubName.hashCode.abs();
    return List.generate(widget.members.length, (i) {
      final item = _itemPool[(i + offset) % _itemPool.length];
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
                                child: Center(
                                  child: Icon(listing.icon, size: 40, color: AppColors.gold),
                                ),
                              ),
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
