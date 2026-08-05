import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/private_club.dart';

/// Join a private club with a one-time access code handed over personally by
/// the club's creator. The code binds this account to the slot and dies. The
/// member keeps the display name the creator set or changes it here.
class JoinPrivateClubPage extends StatefulWidget {
  const JoinPrivateClubPage({super.key});
  @override
  State<JoinPrivateClubPage> createState() => _JoinPrivateClubPageState();
}

class _JoinPrivateClubPageState extends State<JoinPrivateClubPage> {
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  String? _error;
  MemberSlot? _slot;

  void _redeem() {
    final slot = GetIt.instance<PrivateClubState>().redeem(_codeCtrl.text.trim().toUpperCase());
    setState(() {
      if (slot == null) {
        _error = 'That code is unknown or already used.';
      } else {
        _error = null;
        _slot = slot;
        _nameCtrl.text = slot.displayName;
      }
    });
  }

  void _finish() {
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty) _slot!.displayName = name;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Welcome. Your display name is only visible inside this club.')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    return Scaffold(
      appBar: AppBar(title: const Text('Join Private Club')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (_slot == null) ...[
          Text('Enter the access code you were given. It works once.', style: AppTextStyles.body(secondaryText)),
          const SizedBox(height: 12),
          TextField(controller: _codeCtrl, textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(labelText: 'Access code', errorText: _error)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _redeem, child: const Text('Join')),
        ] else ...[
          Text('Code accepted. Set your display name for this club. Members only ever see this name, and it never appears anywhere outside the club.',
              style: AppTextStyles.body(secondaryText)),
          const SizedBox(height: 12),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Display name')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _finish, child: const Text('Enter club')),
        ],
      ]),
    );
  }
}
