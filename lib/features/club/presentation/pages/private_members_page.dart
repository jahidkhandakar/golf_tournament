import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/private_club.dart';

/// Private club Member Management, visible to the creator and sub-admins
/// only. Add a member: enter a display name, pay the per-member fee, receive
/// the one-time access code, hand it over personally. The list shows every
/// slot and whether its code has been redeemed.
class PrivateMembersPage extends StatefulWidget {
  const PrivateMembersPage({super.key, required this.clubId, required this.clubName});
  final String clubId;
  final String clubName;

  @override
  State<PrivateMembersPage> createState() => _PrivateMembersPageState();
}

class _PrivateMembersPageState extends State<PrivateMembersPage> {
  final PrivateClubState _state = GetIt.instance<PrivateClubState>();

  @override
  void initState() { super.initState(); _state.addListener(_onChange); }
  @override
  void dispose() { _state.removeListener(_onChange); super.dispose(); }
  void _onChange() { if (mounted) setState(() {}); }

  Future<void> _addMember() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add member'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Enter a display name for the slot. You pay the member fee now and receive a one-time access code to hand to them personally. They can change the display name once inside.'),
          const SizedBox(height: 10),
          TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Display name')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(ctrl.text.trim()),
            child: const Text('Pay and generate code')),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    final slot = _state.addSlot(widget.clubId, name);
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Access code'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hand this code to $name personally. It works once and dies.'),
          const SizedBox(height: 12),
          SelectableText(slot.code, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ]),
        actions: [
          TextButton(
            onPressed: () { Clipboard.setData(ClipboardData(text: slot.code)); Navigator.of(context).pop(); },
            child: const Text('Copy and close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final slots = _state.slotsFor(widget.clubId);
    return Scaffold(
      appBar: AppBar(title: const Text('Member Management')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(widget.clubName, style: AppTextStyles.heading3(primaryText)),
        const SizedBox(height: 4),
        Text('Private club. You are the only one who knows who your members really are. The app never collects their identity through the invite, and payment exists only on your side.',
            style: AppTextStyles.caption(secondaryText)),
        const SizedBox(height: 14),
        ElevatedButton.icon(icon: const Icon(Icons.person_add_alt), label: const Text('Add member'), onPressed: _addMember),
        const SizedBox(height: 14),
        for (final s in slots)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: s.redeemed ? AppColors.success : AppColors.greyLight),
            ),
            child: Row(children: [
              Icon(s.redeemed ? Icons.check_circle : Icons.vpn_key_outlined,
                  size: 18, color: s.redeemed ? AppColors.success : AppColors.goldDark),
              const SizedBox(width: 10),
              Expanded(child: Text(s.displayName, style: AppTextStyles.body(primaryText))),
              Text(s.redeemed ? 'Joined' : s.code,
                  style: AppTextStyles.caption(s.redeemed ? AppColors.success : secondaryText)),
            ]),
          ),
        if (slots.isEmpty)
          Text('No members yet. Add the first slot above.', style: AppTextStyles.body(secondaryText)),
      ]),
    );
  }
}
