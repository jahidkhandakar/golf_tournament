import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/location/location_state.dart';
import '../../../../core/permission/feature.dart';
import '../../../../core/permission/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/upgrade_prompt.dart';

/// Pushed full-screen from the app bar location pin (no bottom nav).
/// Free tier can view but not change the zone; Paid/Superuser can change
/// freely — gated through [PermissionService.can].
class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  void _onChangeLocation(BuildContext context) {
    final permissionService = GetIt.instance<PermissionService>();
    if (!permissionService.can(Feature.changeLocation)) {
      UpgradePrompt.show(context, message: 'Upgrade to change your home zone.');
      return;
    }
    _showZonePicker(context);
  }

  /// Super Users can have their location auto-detected (mock GPS) instead of
  /// picking a zone by hand — free users are gated to their onboarding zone.
  void _onUseCurrentLocation(BuildContext context) {
    final permissionService = GetIt.instance<PermissionService>();
    if (!permissionService.can(Feature.changeLocation)) {
      UpgradePrompt.show(context, message: 'Upgrade to auto-update your location.');
      return;
    }
    // Mock GPS result.
    GetIt.instance<LocationState>().setZone('Round Rock, TX');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location updated to Round Rock, TX (mock GPS)')),
    );
  }

  void _showZonePicker(BuildContext context) {
    final locationState = GetIt.instance<LocationState>();
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text('Choose your zone', style: Theme.of(sheetContext).textTheme.headlineSmall),
              for (final zone in LocationState.zoneOptions)
                ListTile(
                  title: Text(zone),
                  subtitle: Text('${LocationState.radiusForZone(zone)} mi radius'),
                  trailing: ValueListenableBuilder<String>(
                    valueListenable: locationState.currentZone,
                    builder: (context, currentZone, _) =>
                        currentZone == zone ? const Icon(Icons.check, color: AppColors.gold) : const SizedBox.shrink(),
                  ),
                  onTap: () {
                    locationState.setZone(zone);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationState = GetIt.instance<LocationState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(title: const Text('Location')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, color: AppColors.gold, size: 48),
              const SizedBox(height: 16),
              Text('Current zone', style: AppTextStyles.body(secondaryText)),
              const SizedBox(height: 4),
              ValueListenableBuilder<String>(
                valueListenable: locationState.currentZone,
                builder: (context, zone, _) => Text(zone, style: AppTextStyles.heading2(primaryText)),
              ),
              const SizedBox(height: 4),
              ValueListenableBuilder<int>(
                valueListenable: locationState.radiusMiles,
                builder: (context, radius, _) => Text(
                  'Showing golfers & clubs within $radius mi',
                  style: AppTextStyles.caption(secondaryText),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _onUseCurrentLocation(context),
                  icon: const Icon(Icons.my_location),
                  label: const Text('Use My Current Location'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _onChangeLocation(context),
                  child: const Text('Change Location'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
