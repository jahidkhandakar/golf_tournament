import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/marketplace_listing.dart';

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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(listing.icon, color: AppColors.goldDark, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(listing.title, style: AppTextStyles.bodyBold(primaryText)),
                    const SizedBox(height: 2),
                    Text(
                      '\$${listing.price.toStringAsFixed(0)}',
                      style: AppTextStyles.heading3(AppColors.goldDark),
                    ),
                    const SizedBox(height: 4),
                    Text('${listing.sellerName} · ${listing.location}', style: AppTextStyles.caption(secondaryText)),
                    Text(formatRelativeShort(listing.postedDate), style: AppTextStyles.caption(secondaryText)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
