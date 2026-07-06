import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/user/user_tier.dart';
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
  _DrawerDestination('My Clubs', Icons.sports_golf_outlined, AppRoutes.myClubs),
  _DrawerDestination('Subscription & Payment', Icons.payment_outlined, AppRoutes.subscriptionPayment),
  _DrawerDestination('Settings', Icons.settings_outlined, AppRoutes.settings),
  _DrawerDestination('Help & Support', Icons.help_outline, AppRoutes.helpSupport),
  _DrawerDestination('About & Legal', Icons.info_outline, AppRoutes.aboutLegal),
];

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

    return Column(
      children: [
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: theme.colorScheme.surface),
          currentAccountPicture: const CircleAvatar(
            backgroundColor: AppColors.gold,
            child: Icon(Icons.person, color: AppColors.white, size: 32),
          ),
          accountName: Text(user.name, style: AppTextStyles.heading3(textColor)),
          accountEmail: Align(
            alignment: Alignment.centerLeft,
            // A plain Chip overflows this slot by a few pixels — it has a
            // built-in minimum height too tall for the tight space
            // UserAccountsDrawerHeader gives the accountEmail row.
            child: TagChip(label: user.tier.label, background: user.tier.color, foreground: AppColors.white),
          ),
        ),
        if (user.tier == UserTier.free)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Card(
              color: AppColors.gold.withValues(alpha: 0.12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Go Pro', style: AppTextStyles.heading3(textColor)),
                    const SizedBox(height: 4),
                    Text(
                      'Unlock club management, leaderboards and more.',
                      style: AppTextStyles.body(
                        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          UpgradePrompt.show(
                            context,
                            message: 'Upgrade to GGW Pro to unlock this feature.',
                          );
                        },
                        child: const Text('Upgrade'),
                      ),
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
