import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/club_member.dart';

typedef _ChatMessage = ({String sender, String text, String time});

class ChatTab extends StatelessWidget {
  const ChatTab({super.key, required this.members});

  final List<ClubMember> members;

  List<_ChatMessage> _mockMessages() {
    const bodies = [
      "Who's in for Saturday's tee time?",
      "I'm in — 7:40 works for me.",
      'Can we push to 8:15? Running behind.',
      'Works for me too.',
    ];
    return List.generate(bodies.length, (i) {
      final sender = members.isEmpty ? 'Club Member' : members[i % members.length].name;
      return (sender: sender, text: bodies[i], time: '${9 + i}:0${i}0 AM');
    });
  }

  void _showComposerStub(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Club chat is coming soon (mock)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bubbleColor = isDark ? AppColors.darkSurface : AppColors.greyLight.withValues(alpha: 0.5);
    final messages = _mockMessages();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${message.sender} · ${message.time}',
                      style: AppTextStyles.caption(secondaryText),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(message.text, style: AppTextStyles.body(primaryText)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'Message the club...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _showComposerStub(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
