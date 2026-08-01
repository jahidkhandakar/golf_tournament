import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/user/user_tier.dart';
import '../../../../core/widgets/photo_avatar.dart';
import '../../../../core/widgets/tag_chip.dart';
import '../../../../core/widgets/upgrade_prompt.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/domain/repositories/user_profile_repository.dart';

class _DrawerDestination {
  const _DrawerDestination(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}

const _destinations = [
  _DrawerDestination('Settings', Icons.settings_outlined, AppRoutes.settings),
  _DrawerDestination('Subscription & Payment', Icons.payment_outlined, AppRoutes.subscriptionPayment),
];

// ignore: unused_element
const _removedDestinations = [
  _DrawerDestination('My Clubs', Icons.sports_golf_outlined, AppRoutes.myClubs),
  _DrawerDestination('Tournaments', Icons.emoji_events_outlined, AppRoutes.tournaments),
  _DrawerDestination('Tee Sheet', Icons.event_available_outlined, AppRoutes.teeSheet),
  // Admin-only (Club Creator / sub-admin). Shown to everyone for now; gate on
  // the club role once PermissionService knows about it.
  _DrawerDestination('Tee Sheet Builder', Icons.edit_calendar_outlined, AppRoutes.teeSheetBuilder),
  _DrawerDestination('Marketplace', Icons.storefront_outlined, AppRoutes.marketplace),
  _DrawerDestination('Help & Support', Icons.help_outline, AppRoutes.helpSupport),
  _DrawerDestination('About & Legal', Icons.info_outline, AppRoutes.aboutLegal),
];
// _removedDestinations is kept for reference while these entry points are
// relocated into their features (My Club page, tournament screens, Home
// marketplace, Settings). Remove once relocation lands.

/// Left navigation drawer for the logged-in shell. Deliberately excludes
/// Home/Club/Top 50/Messages/Profile — those already live in the bottom nav.
class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late final Future<UserProfile> _future = GetIt.instance<UserProfileRepository>().getCurrentUser();

  void _navigate(BuildContext context, String route) {
    Navigator.of(context).pop();
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: FutureBuilder<UserProfile>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return _DrawerContent(user: snapshot.data!, onNavigate: _navigate);
          },
        ),
      ),
    );
  }
}

class _DrawerContent extends StatelessWidget {
  const _DrawerContent({required this.user, required this.onNavigate});

  final UserProfile user;
  final void Function(BuildContext context, String route) onNavigate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      children: [
        const SizedBox(height: 8),
        InkWell(
          onTap: () => onNavigate(context, AppRoutes.myProfile),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
            child: Row(
              children: [
                PhotoAvatar(name: user.name, radius: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: AppTextStyles.heading3(textColor)),
                      const SizedBox(height: 4),
                      TagChip(label: user.tier.label, background: user.tier.color, foreground: AppColors.white),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: secondaryText),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        if (user.tier == UserTier.free)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Card(
              margin: EdgeInsets.zero,
              color: AppColors.gold.withValues(alpha: 0.12),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Go Pro', style: AppTextStyles.bodyBold(textColor)),
                          Text('Unlock the full app', style: AppTextStyles.caption(secondaryText)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        UpgradePrompt.show(
                          context,
                          message: 'Upgrade to GGW Pro to unlock this feature.',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Upgrade'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              for (final destination in _destinations)
                ListTile(
                  leading: Icon(destination.icon),
                  title: Text(destination.label),
                  onTap: () => onNavigate(context, destination.route),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.logout, color: AppColors.error),
          title: const Text('Log out', style: TextStyle(color: AppColors.error)),
          onTap: () {
            Navigator.of(context).pop();
            context.go(AppRoutes.login);
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
