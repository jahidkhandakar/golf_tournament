import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/location/location_state.dart';
import '../../../../core/permission/feature.dart';
import '../../../../core/permission/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/upgrade_prompt.dart';

const _zoneOptions = ['Austin, TX', 'Round Rock, TX', 'Cedar Park, TX', 'Dallas, TX'];

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
              for (final zone in _zoneOptions)
                ListTile(
                  title: Text(zone),
                  trailing: ValueListenableBuilder<String>(
                    valueListenable: locationState.currentZone,
                    builder: (context, currentZone, _) =>
                        currentZone == zone ? const Icon(Icons.check, color: AppColors.gold) : const SizedBox.shrink(),
                  ),
                  onTap: () {
                    locationState.currentZone.value = zone;
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
                builder: (context, radius, _) =>
                    Text('$radius mi radius', style: AppTextStyles.caption(secondaryText)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _onChangeLocation(context),
                child: const Text('Change Location'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
