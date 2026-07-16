import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

typedef _Listing = ({String title, String price, String sellerName, IconData icon});

const _listings = <_Listing>[
  (title: 'Titleist Pro V1 (dozen)', price: '\$32', sellerName: 'Marcus T.', icon: Icons.sports_golf),
  (title: 'Left-handed driver, 10.5°', price: '\$110', sellerName: 'Dana R.', icon: Icons.golf_course),
  (title: 'Push cart, barely used', price: '\$65', sellerName: 'Priya K.', icon: Icons.shopping_cart_outlined),
  (title: 'Golf bag, Sun Mountain', price: '\$85', sellerName: 'Sam O.', icon: Icons.backpack_outlined),
];

class MarketplaceTab extends StatefulWidget {
  const MarketplaceTab({super.key});

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final query = _queryController.text.trim().toLowerCase();
    final listings =
        query.isEmpty ? _listings : _listings.where((l) => l.title.toLowerCase().contains(query)).toList();

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
                    : Text('Marketplace', style: AppTextStyles.heading3(primaryText)),
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
                            Text(listing.price, style: AppTextStyles.heading3(AppColors.goldDark)),
                            Text('by ${listing.sellerName}', style: AppTextStyles.caption(secondaryText)),
                          ],
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
