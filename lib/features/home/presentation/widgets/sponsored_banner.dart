import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../marketplace/domain/entities/marketplace_listing.dart';
import '../../../marketplace/domain/repositories/marketplace_repository.dart';

/// Full-width sponsored placement pinned above the tab content. Tapping
/// expands it to reveal more detail plus a link into the sponsored
/// listing's page in the global Marketplace.
class SponsoredBanner extends StatefulWidget {
  const SponsoredBanner({super.key});

  @override
  State<SponsoredBanner> createState() => _SponsoredBannerState();
}

class _SponsoredBannerState extends State<SponsoredBanner> {
  late final Future<MarketplaceListing?> _future =
      GetIt.instance<MarketplaceRepository>().getSponsoredListing();
  bool _expanded = false;

  void _viewInMarketplace(MarketplaceListing listing) {
    context.push(AppRoutes.marketplaceListingDetail(listing.id), extra: listing);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return FutureBuilder<MarketplaceListing?>(
      future: _future,
      builder: (context, snapshot) {
        final listing = snapshot.data;

        return GestureDetector(
          onTap: listing == null ? null : () => setState(() => _expanded = !_expanded),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold, width: 1.5),
              color: AppColors.gold.withValues(alpha: isDark ? 0.14 : 0.08),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(listing?.icon ?? Icons.campaign_outlined, color: AppColors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SPONSORED',
                            style: AppTextStyles.caption(AppColors.goldDark).copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            listing?.title ?? 'Your brand here',
                            style: AppTextStyles.bodyBold(primaryText),
                          ),
                          Text(
                            listing == null
                                ? 'Placeholder sponsor content'
                                : '\$${listing.price.toStringAsFixed(0)} · ${listing.sellerName}',
                            style: AppTextStyles.caption(secondaryText),
                          ),
                        ],
                      ),
                    ),
                    if (listing != null)
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        color: secondaryText,
                      ),
                  ],
                ),
                if (_expanded && listing != null) ...[
                  const SizedBox(height: 12),
                  Text(listing.description, style: AppTextStyles.body(secondaryText)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _viewInMarketplace(listing),
                      child: const Text('View in Marketplace'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
