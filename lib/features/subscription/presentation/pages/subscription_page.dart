import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/user/user_tier.dart';
import '../../../../core/widgets/info_dialog.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/domain/repositories/user_profile_repository.dart';

class _Plan {
  const _Plan(this.tier, this.price, this.features);

  final UserTier tier;
  final String price;
  final List<String> features;
}

const _plans = [
  _Plan(UserTier.free, '\$0/mo', [
    '2 free outings per month',
    'Browse gaggles, outings & players',
    'Unlimited messaging',
  ]),
  _Plan(UserTier.paid, '\$9.99/mo', [
    'Unlimited outings',
    'Post to Looking to Play',
    'Challenge other players',
  ]),
  _Plan(UserTier.superuser, '\$24.99/mo', [
    'Everything in Paid',
    'Change your home zone anytime',
    'Priority club review on requests',
  ]),
];

/// View-only — no real billing is wired up. Selecting a plan just shows a
/// mock confirmation.
class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  late final Future<UserProfile> _future = GetIt.instance<UserProfileRepository>().getCurrentUser();

  void _choosePlan(UserTier tier) {
    InfoDialog.show(
      context,
      title: 'Plan Selected',
      message: "You've selected the ${tier.label} plan. Payment isn't wired up yet — this is a preview (mock).",
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription & Payment')),
      body: FutureBuilder<UserProfile>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final currentTier = snapshot.data!.tier;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Current plan', style: AppTextStyles.body(secondaryText)),
              const SizedBox(height: 4),
              Text(currentTier.label, style: AppTextStyles.heading2(currentTier.color)),
              const SizedBox(height: 20),
              for (final plan in _plans) ...[
                _PlanCard(
                  plan: plan,
                  isCurrent: plan.tier == currentTier,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  onChoose: () => _choosePlan(plan.tier),
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isCurrent,
    required this.primaryText,
    required this.secondaryText,
    required this.onChoose,
  });

  final _Plan plan;
  final bool isCurrent;
  final Color primaryText;
  final Color secondaryText;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCurrent ? const BorderSide(color: AppColors.gold, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(plan.tier.label, style: AppTextStyles.heading3(primaryText))),
                Text(plan.price, style: AppTextStyles.heading3(AppColors.goldDark)),
              ],
            ),
            const SizedBox(height: 12),
            for (final feature in plan.features)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, size: 16, color: AppColors.success),
                    const SizedBox(width: 6),
                    Expanded(child: Text(feature, style: AppTextStyles.body(secondaryText))),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: isCurrent
                  ? OutlinedButton(onPressed: null, child: const Text('Current Plan'))
                  : ElevatedButton(onPressed: onChoose, child: const Text('Choose Plan')),
            ),
          ],
        ),
      ),
    );
  }
}
