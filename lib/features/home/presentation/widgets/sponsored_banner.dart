import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/location/location_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Zone-targeted sponsored ad window. Pinned at the top of the Home tab (fixed
/// — it does not scroll with the category content below it).
///
/// Sized deliberately large: this is the app's primary ad inventory, so it
/// takes roughly a quarter of the screen, which leaves one full listing plus a
/// sliver of the next below it — enough to signal that the list scrolls.
///
/// Per the build: advertisers pay a listing fee through the Admin panel
/// (Stripe), the App Admin approves the banner, and it targets a city zone.
/// In a large city each quadrant (for example Chicago North) is its own
/// targetable zone, so users only see banners bought for the zone they are in.
///
/// Mock note: until the backend is wired this renders a single full-size
/// placeholder campaign for the user's current zone from LocationState. The
/// real implementation fetches the active approved banner for the caller's
/// zone_id and renders the advertiser's image with a tap through to their link.
class SponsoredBanner extends StatelessWidget {
  const SponsoredBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final zone = GetIt.instance<LocationState>().currentZone.value;
    // Scale with the screen so the ad keeps its share of the page on any
    // device, clamped so it never crowds out the listings on small phones or
    // balloons on tablets.
    final adHeight =
        (MediaQuery.sizeOf(context).height * 0.23).clamp(170.0, 260.0);

    return Container(
      height: adHeight,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        // Opaque fill (gold tint composited over the surface) so the pinned
        // banner never lets scrolling content bleed through behind it.
        color: Color.alphaBlend(
          AppColors.gold.withValues(alpha: 0.08),
          isDark ? AppColors.darkSurface : AppColors.lightSurface,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.40)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening sponsor (mock)')),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.campaign_outlined, size: 16, color: AppColors.goldDark),
                    const SizedBox(width: 6),
                    Text('SPONSORED', style: AppTextStyles.caption(AppColors.goldDark)),
                    const Spacer(),
                    Text(zone, style: AppTextStyles.caption(secondaryText)),
                  ],
                ),
                const SizedBox(height: 10),
                // Fills the remaining height so the creative — not padding —
                // gets the extra space.
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Advertiser image placeholder (the real banner renders
                      // the approved campaign image here).
                      AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.image_outlined,
                              size: 40, color: AppColors.goldDark),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Your ad here',
                              style: AppTextStyles.heading3(primaryText),
                            ),
                            const SizedBox(height: 6),
                            Flexible(
                              child: Text(
                                'Reach golfers in $zone. Advertise your club, shop, or event right here.',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption(secondaryText),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Learn more',
                                    style: AppTextStyles.caption(AppColors.goldDark)),
                                const Icon(Icons.chevron_right,
                                    size: 16, color: AppColors.goldDark),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
