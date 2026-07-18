import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../marketplace/domain/entities/marketplace_listing.dart';
import '../../../marketplace/domain/repositories/marketplace_repository.dart';

/// Slim, single-line sponsored strip designed to sit as the first item in a
/// scrolling list, so it's visible on landing but scrolls away as you browse.
/// Tapping it opens the sponsored product in the global Marketplace.
class SponsoredBanner extends StatefulWidget {
  const SponsoredBanner({super.key});

  @override
  State<SponsoredBanner> createState() => _SponsoredBannerState();
}

class _SponsoredBannerState extends State<SponsoredBanner> {
  late final Future<MarketplaceListing?> _future =
      GetIt.instance<MarketplaceRepository>().getSponsoredListing();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MarketplaceListing?>(
      future: _future,
      builder: (context, snapshot) {
        final listing = snapshot.data;
        if (listing == null) return const SizedBox.shrink();

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Material(
            color: AppColors.gold.withValues(alpha: isDark ? 0.16 : 0.09),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.push(AppRoutes.marketplaceListingDetail(listing.id), extra: listing),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.campaign_outlined, size: 18, color: AppColors.gold),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'SPONSORED  ',
                              style: AppTextStyles.caption(AppColors.goldDark)
                                  .copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5),
                            ),
                            TextSpan(text: listing.title, style: AppTextStyles.bodyBold(primaryText)),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('\$${listing.price.toStringAsFixed(0)}', style: AppTextStyles.bodyBold(AppColors.goldDark)),
                    Icon(Icons.chevron_right, size: 18, color: secondaryText),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
