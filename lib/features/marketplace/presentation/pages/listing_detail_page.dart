import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../messages/presentation/open_seller_chat.dart';
import '../../domain/entities/marketplace_listing.dart';

class ListingDetailPage extends StatelessWidget {
  const ListingDetailPage({super.key, required this.listing});

  final MarketplaceListing listing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(title: Text(listing.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(listing.icon, color: AppColors.goldDark, size: 72),
          ),
          const SizedBox(height: 16),
          Text(listing.title, style: AppTextStyles.heading2(primaryText)),
          const SizedBox(height: 4),
          Text('\$${listing.price.toStringAsFixed(0)}', style: AppTextStyles.heading1(AppColors.goldDark)),
          const SizedBox(height: 16),
          _DetailRow(icon: Icons.person_outline, text: listing.sellerName, color: secondaryText, primary: primaryText),
          _DetailRow(icon: Icons.location_on_outlined, text: listing.location, color: secondaryText, primary: primaryText),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            text: 'Posted ${formatShortDate(listing.postedDate)}',
            color: secondaryText,
            primary: primaryText,
          ),
          const SizedBox(height: 16),
          Text('Description', style: AppTextStyles.heading3(primaryText)),
          const SizedBox(height: 8),
          Text(listing.description, style: AppTextStyles.body(primaryText)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => openSellerChat(
                context,
                sellerName: listing.sellerName,
                title: listing.title,
                price: '\$${listing.price.toStringAsFixed(0)}',
                icon: listing.icon,
              ),
              icon: const Icon(Icons.chat_bubble_outline),
              label: Text('Message ${listing.sellerName.split(' ').first}'),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.greyLight.withValues(alpha: isDark ? 0.15 : 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: secondaryText, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "GGW Connect doesn't handle payments — message the seller to arrange the deal in person.",
                    style: AppTextStyles.caption(secondaryText),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text, required this.color, required this.primary});

  final IconData icon;
  final String text;
  final Color color;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: AppTextStyles.body(primary)),
        ],
      ),
    );
  }
}
