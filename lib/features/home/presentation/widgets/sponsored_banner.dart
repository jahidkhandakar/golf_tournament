import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/location/location_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Zone targeted sponsored banner. Sits as the first item in the home feed.
///
/// Per the build: advertisers pay a listing fee through the Admin panel
/// (Stripe), the App Admin approves the banner, and it targets a city zone.
/// In a large city each quadrant (for example Chicago North) is its own
/// targetable zone, so users only see banners bought for the zone they are in.
///
/// Mock note: until the backend is wired this renders a placeholder campaign
/// for the user's current zone from LocationState. The real implementation
/// fetches the active approved banner for the caller's zone_id and renders the
/// advertiser's image with a tap through to their link.
class SponsoredBanner extends StatelessWidget {
  const SponsoredBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final zone = GetIt.instance<LocationState>().currentZone.value;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign_outlined, size: 20, color: AppColors.goldDark),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sponsored', style: AppTextStyles.caption(secondaryText)),
                Text(
                  'Your ad here for golfers in $zone',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyBold(
                    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
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
