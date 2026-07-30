import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/permission/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/tag_chip.dart';
import '../../domain/entities/invite.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/repositories/invite_repository.dart';

/// Club Creator / sub-admin screen to invite players into a tournament (§1) and
/// see the status of invites already sent.
class InvitePlayersPage extends StatefulWidget {
  const InvitePlayersPage({super.key, required this.tournament});

  final Tournament tournament;

  @override
  State<InvitePlayersPage> createState() => _InvitePlayersPageState();
}

class _InvitePlayersPageState extends State<InvitePlayersPage> {
  final InviteRepository _repo = GetIt.instance<InviteRepository>();
  final PermissionService _permission = GetIt.instance<PermissionService>();
  final _nameController = TextEditingController();

  List<Invite> _sent = [];
  bool _loading = true;
  bool _busy = false;

  bool get _canInvite => _permission.canApproveRequests(widget.tournament.clubName);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final sent = _canInvite ? await _repo.sentInvites(widget.tournament.id) : <Invite>[];
    if (!mounted) return;
    setState(() {
      _sent = sent;
      _loading = false;
    });
  }

  Future<void> _send() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _busy = true);
    await _repo.invite(
      tournamentId: widget.tournament.id,
      clubName: widget.tournament.clubName,
      playerName: name,
    );
    _nameController.clear();
    await _load();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(title: const Text('Invite Players')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_canInvite
              ? Center(child: Text('Admins only', style: AppTextStyles.body(secondaryText)))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Invite a player to ${widget.tournament.name}. They can accept to join directly.',
                        style: AppTextStyles.caption(secondaryText)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _busy ? null : _send(),
                            decoration: const InputDecoration(hintText: 'Player name'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _busy ? null : _send,
                          child: const Text('Invite'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Sent invites · ${_sent.length}', style: AppTextStyles.bodyBold(primaryText)),
                    const SizedBox(height: 8),
                    if (_sent.isEmpty)
                      Text('No invites sent yet.', style: AppTextStyles.caption(secondaryText))
                    else
                      for (final invite in _sent) _inviteRow(invite, primaryText, secondaryText),
                  ],
                ),
    );
  }

  Widget _inviteRow(Invite invite, Color primaryText, Color secondaryText) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(invite.playerName, style: AppTextStyles.bodyBold(primaryText)),
        subtitle: Text('Invited ${formatRelativeShort(invite.invitedAt)}', style: AppTextStyles.caption(secondaryText)),
        trailing: _statusChip(invite.status),
      ),
    );
  }

  Widget _statusChip(InviteStatus status) {
    switch (status) {
      case InviteStatus.pending:
        return const TagChip(label: 'Pending', background: Color(0x22ED6C02), foreground: AppColors.warning);
      case InviteStatus.accepted:
        return const TagChip(label: 'Accepted', background: Color(0x222E7D32), foreground: AppColors.success);
      case InviteStatus.declined:
        return const TagChip(label: 'Declined', background: Color(0x22D32F2F), foreground: AppColors.error);
    }
  }
}
