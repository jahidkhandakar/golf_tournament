import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/marketplace_listing.dart';

/// Grid tile for a marketplace listing — image placeholder on top, details
/// below.
class ListingCard extends StatelessWidget {
  const ListingCard({super.key, required this.listing, required this.onTap});

  final MarketplaceListing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(listing.icon, color: AppColors.goldDark, size: 36),
                ),
              ),
              const SizedBox(height: 8),
              Text(listing.title, style: AppTextStyles.bodyBold(primaryText), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text('\$${listing.price.toStringAsFixed(0)}', style: AppTextStyles.heading3(AppColors.goldDark)),
              const SizedBox(height: 2),
              Text(listing.sellerName, style: AppTextStyles.caption(secondaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(formatRelativeShort(listing.postedDate), style: AppTextStyles.caption(secondaryText)),
            ],
          ),
        ),
      ),
    );
  }
}
