import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/location/location_state.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

enum _LocationStep { idle, detecting, done }

/// Last step of onboarding, before entering the app shell. GPS is mocked —
/// "Use My Location" just sets a hardcoded zone after a short delay.
class LocationPermissionPage extends StatefulWidget {
  const LocationPermissionPage({super.key});

  @override
  State<LocationPermissionPage> createState() => _LocationPermissionPageState();
}

class _LocationPermissionPageState extends State<LocationPermissionPage> {
  _LocationStep _step = _LocationStep.idle;

  static const String _mockZone = 'Austin, TX';

  Future<void> _useMyLocation() async {
    setState(() => _step = _LocationStep.detecting);
    await Future.delayed(const Duration(milliseconds: 900));
    GetIt.instance<LocationState>().currentZone.value = _mockZone;
    if (mounted) setState(() => _step = _LocationStep.done);
  }

  void _continue() => context.go(AppRoutes.home);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, color: AppColors.gold, size: 56),
                const SizedBox(height: 20),
                Text('Enable Location', style: AppTextStyles.heading1(primaryText), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'We use your location to find gaggles, outings and players near you.',
                  style: AppTextStyles.body(secondaryText),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (_step == _LocationStep.idle)
                  ElevatedButton.icon(
                    onPressed: _useMyLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Use My Location'),
                  )
                else if (_step == _LocationStep.detecting)
                  const Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.gold),
                      SizedBox(height: 12),
                      Text('Detecting your location...'),
                    ],
                  )
                else ...[
                  Icon(Icons.check_circle, color: AppColors.success, size: 32),
                  const SizedBox(height: 8),
                  Text('Location set to $_mockZone', style: AppTextStyles.bodyBold(primaryText)),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _continue, child: const Text('Continue to GGW Connect')),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
