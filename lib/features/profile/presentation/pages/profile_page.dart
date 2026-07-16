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
  late final Future<_ProfileData> _future = _load();

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

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              ProfileHeader(name: data.user.name, tier: data.user.tier, handicap: data.user.handicap),
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
