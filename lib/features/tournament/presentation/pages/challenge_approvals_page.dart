import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/permission/club_role.dart';
import '../../../../core/permission/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/challenge_approval.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/repositories/challenge_approval_repository.dart';

/// Club Creator / sub-admin queue for approving same-club, in-tournament
/// challenges (§3). Approving confirms the challenge so it counts; the ladder
/// result is applied later, when the round's scorecard is submitted (§6).
class ChallengeApprovalsPage extends StatefulWidget {
  const ChallengeApprovalsPage({super.key, required this.tournament});

  final Tournament tournament;

  @override
  State<ChallengeApprovalsPage> createState() => _ChallengeApprovalsPageState();
}

class _ChallengeApprovalsPageState extends State<ChallengeApprovalsPage> {
  final ChallengeApprovalRepository _repo = GetIt.instance<ChallengeApprovalRepository>();
  final PermissionService _permission = GetIt.instance<PermissionService>();

  List<ChallengeApproval> _pending = [];
  bool _loading = true;
  bool _busy = false;

  bool get _canApprove => _permission.canApproveChallenges(widget.tournament.clubName);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final pending = _canApprove ? await _repo.pending(widget.tournament.id) : <ChallengeApproval>[];
    if (!mounted) return;
    setState(() {
      _pending = pending;
      _loading = false;
    });
  }

  Future<void> _approve(ChallengeApproval c) async {
    setState(() => _busy = true);
    // Approving only confirms the challenge — the ladder result is applied when
    // the round's scorecard is submitted.
    await _repo.approve(c.id);
    await _load();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _reject(ChallengeApproval c) async {
    setState(() => _busy = true);
    await _repo.reject(c.id);
    await _load();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(title: const Text('Challenge Approvals')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_canApprove
              ? _denied(primaryText, secondaryText)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Same-club challenges need your approval before they count toward the Club Leaderboard and Top 50.',
                      style: AppTextStyles.caption(secondaryText),
                    ),
                    const SizedBox(height: 16),
                    if (_pending.isEmpty)
                      Text('No challenges waiting.', style: AppTextStyles.body(secondaryText))
                    else
                      for (final challenge in _pending) _card(challenge, primaryText, secondaryText),
                  ],
                ),
    );
  }

  Widget _card(ChallengeApproval c, Color primaryText, Color secondaryText) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyBold(primaryText),
                      children: [
                        TextSpan(text: c.challengerName),
                        TextSpan(text: '  vs  ', style: AppTextStyles.caption(secondaryText)),
                        TextSpan(text: c.opponentName),
                      ],
                    ),
                  ),
                ),
                Text(formatRelativeShort(c.createdAt), style: AppTextStyles.caption(secondaryText)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _busy ? null : () => _reject(c),
                  child: Text('Reject', style: AppTextStyles.bodyBold(AppColors.error)),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: _busy ? null : () => _approve(c),
                  child: const Text('Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _denied(Color primaryText, Color secondaryText) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 40, color: secondaryText),
              const SizedBox(height: 12),
              Text('Admins only', style: AppTextStyles.heading3(primaryText)),
              const SizedBox(height: 6),
              Text('Only ${ClubRole.creator.label}s and sub-admins can approve challenges.',
                  textAlign: TextAlign.center, style: AppTextStyles.body(secondaryText)),
            ],
          ),
        ),
      );
}
