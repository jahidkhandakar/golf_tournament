import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/assets/app_images.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../messages/domain/repositories/conversation_repository.dart';
import '../../domain/entities/nearby_golfer.dart';

/// Pushed full-screen when tapping a golfer tile on the Profile tab.
class GolferProfilePage extends StatelessWidget {
  const GolferProfilePage({super.key, required this.golfer});

  final NearbyGolfer golfer;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) return parts.isEmpty ? '?' : parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Future<void> _message(BuildContext context) async {
    final conversation =
        await GetIt.instance<ConversationRepository>().getOrCreateConversationWith(golfer.name);
    if (context.mounted) {
      context.push(AppRoutes.chatDetail(conversation.id), extra: conversation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(title: Text(golfer.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: () => ImagePreview.show(context, AppImages.person(golfer.name)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                AppImages.person(golfer.name),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.2),
                cacheWidth: 800,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: AppColors.gold,
                  alignment: Alignment.center,
                  child: Text(_initials(golfer.name), style: AppTextStyles.heading1(AppColors.white)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(golfer.name, style: AppTextStyles.heading2(primaryText)),
          const SizedBox(height: 24),
          _InfoRow(icon: Icons.sports_golf_outlined, label: 'Home club', value: golfer.homeClub, primaryText: primaryText, secondaryText: secondaryText),
          _InfoRow(icon: Icons.golf_course_outlined, label: 'Rounds played', value: '${golfer.roundsPlayed}', primaryText: primaryText, secondaryText: secondaryText),
          _InfoRow(icon: Icons.near_me_outlined, label: 'Distance', value: '${golfer.distanceMiles.toStringAsFixed(1)} mi away', primaryText: primaryText, secondaryText: secondaryText),
          const SizedBox(height: 16),
          Text('About', style: AppTextStyles.heading3(primaryText)),
          const SizedBox(height: 8),
          Text(golfer.bio, style: AppTextStyles.body(secondaryText)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _message(context),
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Message'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.primaryText,
    required this.secondaryText,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color primaryText;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: secondaryText),
          const SizedBox(width: 8),
          Text('$label: ', style: AppTextStyles.caption(secondaryText)),
          Expanded(child: Text(value, style: AppTextStyles.bodyBold(primaryText))),
        ],
      ),
    );
  }
}
