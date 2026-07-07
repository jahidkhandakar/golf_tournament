import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/tag_chip.dart';
import '../../domain/entities/club_membership.dart';
import '../../domain/repositories/club_membership_repository.dart';

class MyClubsPage extends StatefulWidget {
  const MyClubsPage({super.key});

  @override
  State<MyClubsPage> createState() => _MyClubsPageState();
}

class _MyClubsPageState extends State<MyClubsPage> {
  late final Future<List<ClubMembership>> _future =
      GetIt.instance<ClubMembershipRepository>().getMyClubs();

  void _onTapClub(ClubMembership membership) {
    if (membership.isHomeClub) {
      context.go(AppRoutes.club);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Switching home club to ${membership.clubName} is coming soon (mock)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(title: const Text('My Clubs')),
      body: FutureBuilder<List<ClubMembership>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final memberships = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final membership in memberships)
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => _onTapClub(membership),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.sports_golf, color: AppColors.white),
                    ),
                    title: Text(membership.clubName, style: AppTextStyles.bodyBold(primaryText)),
                    subtitle: Text(
                      '${membership.location} · ${membership.memberCount} members',
                      style: AppTextStyles.caption(secondaryText),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TagChip(
                          label: membership.role == ClubRole.admin ? 'Admin' : 'Member',
                          background: AppColors.gold.withValues(alpha: 0.16),
                          foreground: AppColors.goldDark,
                        ),
                        if (membership.isHomeClub) ...[
                          const SizedBox(height: 4),
                          Text('Home club', style: AppTextStyles.caption(secondaryText)),
                        ],
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.explore_outlined),
                label: const Text('Find more clubs'),
              ),
            ],
          );
        },
      ),
    );
  }
}
