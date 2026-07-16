import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/info_dialog.dart';

typedef _Faq = ({String question, String answer});

const _faqs = <_Faq>[
  (
    question: 'What is a "Club"?',
    answer:
        "A Club is a tournament round hosted by a golf club. You can request to play in one from the "
        "Home tab, and the club will review and confirm your spot."
  ),
  (
    question: "What's the difference between a Club and an Outing?",
    answer:
        'Clubs are tournaments hosted by golf clubs. Outings are casual, player-organized rounds — lighter '
        "weight, capped at 10 players, and never counted toward your handicap."
  ),
  (
    question: 'How does Looking to Play work?',
    answer:
        'Post your location, available dates and preferred formats, and nearby golfers can invite you '
        'to their club or message you directly to set something up.'
  ),
  (
    question: 'Can I cancel a request to play?',
    answer:
        "Not yet from the app — for now, message the club directly and they'll take care of it."
  ),
  (
    question: 'How do challenges work?',
    answer:
        "Challenge another player from the Top 50 leaderboard. If they accept, you'll both get notified "
        'with details on scheduling your match.'
  ),
];

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  void _contactSupport(BuildContext context) {
    InfoDialog.show(
      context,
      title: 'Support Request Sent',
      message: "Your message has been sent (mock). We'll get back to you within 24 hours.",
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Frequently Asked Questions', style: AppTextStyles.heading3(primaryText)),
          const SizedBox(height: 8),
          for (final faq in _faqs)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                title: Text(faq.question, style: AppTextStyles.bodyBold(primaryText)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(faq.answer, style: AppTextStyles.body(secondaryText))],
              ),
            ),
          const SizedBox(height: 16),
          Text('Still need help?', style: AppTextStyles.heading3(primaryText)),
          const SizedBox(height: 8),
          Text(
            "Send us a message and we'll get back to you as soon as we can.",
            style: AppTextStyles.body(secondaryText),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _contactSupport(context),
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }
}
