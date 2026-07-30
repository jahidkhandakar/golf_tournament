import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/round.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/challenge_repository.dart';
import '../../domain/repositories/round_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../widgets/challenge_history_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats_section.dart';
import '../widgets/round_history_section.dart';

typedef _ProfileData = ({UserProfile user, List<Round> rounds, List<Challenge> challenges});

/// The current user's own profile — reached from the drawer header, pushed
/// on top of the shell (so it gets its own AppBar with a back button).
/// Account-level settings live in the drawer — this screen is about the
/// golfer. The Profile tab itself now shows nearby golfers instead.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<_ProfileData> _future = _load();

  void _refresh() => setState(() => _future = _load());

  Future<_ProfileData> _load() async {
    final user = await GetIt.instance<UserProfileRepository>().getCurrentUser();
    final rounds = await GetIt.instance<RoundRepository>().getRoundHistory();
    final challenges = await GetIt.instance<ChallengeRepository>().getChallengeHistory();
    return (user: user, rounds: rounds, challenges: challenges);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: FutureBuilder<_ProfileData>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

          final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              ProfileHeader(
                name: data.user.name,
                tier: data.user.tier,
                clubHandicap: data.user.clubHandicap,
                globalHandicap: data.user.globalHandicap,
                homeClub: data.user.homeClub,
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ListTile(
                  leading: const Icon(Icons.emoji_events_outlined, color: AppColors.gold),
                  title: Text('Currently playing', style: AppTextStyles.caption(secondaryText)),
                  subtitle: Text(
                    '${data.user.currentTournament}\n${data.user.currentCourse}',
                    style: AppTextStyles.bodyBold(primaryText),
                  ),
                  isThreeLine: true,
                ),
              ),
              const SizedBox(height: 8),
              _GlobalHandicapCard(user: data.user, onChanged: _refresh),
              const SizedBox(height: 8),
              ProfileStatsSection(rounds: data.rounds),
              const SizedBox(height: 16),
              _SectionTitle(title: 'Round History', color: primaryText),
              RoundHistorySection(rounds: data.rounds),
              const SizedBox(height: 16),
              _SectionTitle(title: 'Challenge History', color: primaryText),
              ChallengeHistorySection(challenges: data.challenges),
            ],
          );
        },
      ),
    );
  }
}

/// Publish or clear the optional global handicap shown to golfers worldwide
/// (§ item 6).
class _GlobalHandicapCard extends StatelessWidget {
  const _GlobalHandicapCard({required this.user, required this.onChanged});

  final UserProfile user;
  final VoidCallback onChanged;

  Future<void> _edit(BuildContext context) async {
    final controller = TextEditingController(text: user.globalHandicap?.toString() ?? '');
    final result = await showDialog<({bool save, String? text})>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Global handicap'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: 'e.g. 6.9 — visible worldwide'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          if (user.globalHandicap != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop((save: true, text: null)),
              child: Text('Remove', style: AppTextStyles.bodyBold(AppColors.error)),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop((save: true, text: controller.text.trim())),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null || !result.save) return;

    final text = result.text;
    // Null (Remove) or an empty field clears the handicap.
    if (text == null || text.isEmpty) {
      await GetIt.instance<UserProfileRepository>().updateGlobalHandicap(null);
      onChanged();
      return;
    }
    // Reject invalid input instead of silently clearing it.
    final value = double.tryParse(text);
    if (value == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid handicap number.')),
        );
      }
      return;
    }
    await GetIt.instance<UserProfileRepository>().updateGlobalHandicap(value);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final hcp = user.globalHandicap;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        leading: const Icon(Icons.public, color: AppColors.goldDark),
        title: Text(
          hcp != null ? 'Global handicap ${hcp.toStringAsFixed(1)}' : 'Global handicap not published',
          style: AppTextStyles.bodyBold(primaryText),
        ),
        subtitle: Text(
          hcp != null ? 'Visible to golfers worldwide' : 'Optional — publish it for play elsewhere',
          style: AppTextStyles.caption(secondaryText),
        ),
        trailing: TextButton(onPressed: () => _edit(context), child: Text(hcp != null ? 'Edit' : 'Add')),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(title, style: AppTextStyles.heading3(color)),
    );
  }
}
