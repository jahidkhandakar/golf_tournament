import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotifications = true;
  bool _emailUpdates = false;
  bool _metricUnits = false;
  bool _showProfileNearby = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final themeController = GetIt.instance<ThemeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _SectionHeader(title: 'Appearance', color: secondaryText),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeController.themeMode,
            builder: (context, mode, _) {
              final isDarkMode = mode == ThemeMode.dark ||
                  (mode == ThemeMode.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark);
              return SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark Mode'),
                value: isDarkMode,
                onChanged: (_) => themeController.toggle(MediaQuery.platformBrightnessOf(context)),
              );
            },
          ),
          _SectionHeader(title: 'Notifications', color: secondaryText),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_none),
            title: const Text('Push Notifications'),
            subtitle: const Text('Requests, challenges, tee sheets and invites'),
            value: _pushNotifications,
            onChanged: (value) => setState(() => _pushNotifications = value),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.mail_outline),
            title: const Text('Email Updates'),
            subtitle: const Text('Weekly digest of club activity'),
            value: _emailUpdates,
            onChanged: (value) => setState(() => _emailUpdates = value),
          ),
          _SectionHeader(title: 'Units', color: secondaryText),
          SwitchListTile(
            secondary: const Icon(Icons.straighten_outlined),
            title: const Text('Metric Units'),
            subtitle: Text(_metricUnits ? 'Distances shown in meters' : 'Distances shown in yards'),
            value: _metricUnits,
            onChanged: (value) => setState(() => _metricUnits = value),
          ),
          _SectionHeader(title: 'Privacy', color: secondaryText),
          SwitchListTile(
            secondary: const Icon(Icons.visibility_outlined),
            title: const Text('Show My Profile to Nearby Golfers'),
            subtitle: const Text('Lets others find you on Looking to Play'),
            value: _showProfileNearby,
            onChanged: (value) => setState(() => _showProfileNearby = value),
          ),
          _SectionHeader(title: 'Support', color: secondaryText),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () => context.push(AppRoutes.helpSupport),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About & Legal'),
            onTap: () => context.push(AppRoutes.aboutLegal),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(title, style: AppTextStyles.caption(color).copyWith(fontWeight: FontWeight.w700)),
    );
  }
}
