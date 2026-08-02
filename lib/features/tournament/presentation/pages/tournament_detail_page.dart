import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/permission/club_role.dart';
import '../../../../core/location/location_state.dart';
import '../../../../core/play/trial_controller.dart';
import '../../../../core/permission/permission_service.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/user/user_tier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/upgrade_prompt.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/domain/repositories/user_profile_repository.dart';
import '../../domain/entities/invite.dart';
import '../../domain/entities/play_request.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/live_results.dart';
import '../../domain/repositories/challenge_approval_repository.dart';
import '../../domain/repositories/invite_repository.dart';
import '../../domain/repositories/registration_repository.dart';
import '../widgets/live_results_panel.dart';

/// Tournament detail + registration (§1). The call-to-action is role-aware:
/// members register directly, non-members Request to Play, and a Club Creator /
/// sub-admin sees the pending-request queue with Accept / Reject.
class TournamentDetailPage extends StatefulWidget {
  const TournamentDetailPage({super.key, required this.tournament});

  final Tournament tournament;

  @override
  State<TournamentDetailPage> createState() => _TournamentDetailPageState();
}

class _TournamentDetailPageState extends State<TournamentDetailPage> {
  final RegistrationRepository _reg = GetIt.instance<RegistrationRepository>();
  final ChallengeApprovalRepository _challenges = GetIt.instance<ChallengeApprovalRepository>();
  final InviteRepository _invites = GetIt.instance<InviteRepository>();
  final PermissionService _permission = GetIt.instance<PermissionService>();

  late final ClubRole _role = _permission.roleInClub(widget.tournament.clubName);

  UserProfile? _user;
  int _count = 0;
  bool _registered = false;
  PlayRequest? _myRequest;
  Invite? _myInvite;
  List<PlayRequest> _pending = [];
  int _pendingChallenges = 0;
  bool _resultsFinal = false;
  bool _loading = true;
  bool _busy = false;

  String get _tid => widget.tournament.id;
  bool get _isFull => _count >= widget.tournament.capacity;
  bool get _locked => widget.tournament.isRosterLocked;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = _user ?? await GetIt.instance<UserProfileRepository>().getCurrentUser();
    final count = await _reg.registeredCount(_tid);
    final pending = _role.isStaff ? await _reg.pendingRequests(_tid) : <PlayRequest>[];
    final pendingChallenges = _role.isStaff ? await _challenges.pendingCount(_tid) : 0;
    final registered = _role.isStaff ? false : await _reg.isRegistered(_tid, user.name);
    final myRequest =
        _role == ClubRole.nonMember ? await _reg.myRequest(_tid, user.name) : null;
    final myInvite = _role.isStaff ? null : await _invites.inviteFor(_tid, user.name);
    final resultsFinal = GetIt.instance<LiveResultsRegistry>().existing(_tid)?.isFinal ?? false;
    if (!mounted) return;
    setState(() {
      _user = user;
      _count = count;
      _pending = pending;
      _pendingChallenges = pendingChallenges;
      _registered = registered;
      _myRequest = myRequest;
      _myInvite = myInvite;
      _resultsFinal = resultsFinal;
      _loading = false;
    });
  }

  /// Direct member registration with the free tier travel gate: joining a
  /// tournament outside the user's current home zone consumes a travel trial
  /// (2 per free account, independent of the home Small Outing counter). Paid
  /// users and Superusers skip the gate entirely.
  Future<void> _registerWithTravelGate(BuildContext context) async {
    final t = widget.tournament;
    final user = _user;
    if (user == null) return;
    final isFree = user.tier == UserTier.free;
    final homeZone = GetIt.instance<LocationState>().currentZone.value;
    final outsideZone = t.zone != null && t.zone != homeZone;
    if (isFree && outsideZone) {
      final trials = GetIt.instance<TrialController>();
      if (!trials.canUseTravelTrial) {
        await UpgradePrompt.show(
          context,
          message:
              "You've used your ${TrialController.limitPerCounter} free travel trials. Upgrade to join events anywhere.",
        );
        return;
      }
      trials.useTravelTrial();
    }
    await _run(() => _reg.registerMember(_tid, user.name));
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    await action();
    await _load();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tournament;

    return Scaffold(
      appBar: AppBar(title: Text(t.name)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _InfoCard(tournament: t, registered: _count, isFull: _isFull),
                const SizedBox(height: 16),
                // Once results are final, the live results board replaces the
                // registration flow as the tournament's home (§6).
                if (_resultsFinal)
                  LiveResultsPanel(tournamentId: _tid)
                else ...[
                  _LockBanner(tournament: t),
                  const SizedBox(height: 16),
                  _roleSection(),
                ],
              ],
            ),
    );
  }

  Widget _roleSection() {
    if (_role.isStaff) return _AdminPanel(state: this);
    // Registered wins over everything (covers direct join, approved request, and
    // accepted invite — regardless of member vs non-member).
    if (_registered) {
      return const _StatusTile(
        icon: Icons.check_circle_outline,
        color: AppColors.success,
        title: "You're registered",
        subtitle: "You're in this tournament. See the tee sheet once it's published.",
      );
    }
    // A pending invite takes precedence over the normal register / request CTA.
    if (_myInvite?.status == InviteStatus.pending) return _InviteActions(state: this);
    if (_role == ClubRole.member) return _MemberActions(state: this);
    return _NonMemberActions(state: this);
  }
}

class _InviteActions extends StatelessWidget {
  const _InviteActions({required this.state});

  final _TournamentDetailPageState state;

  @override
  Widget build(BuildContext context) {
    final invite = state._myInvite!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusTile(
          icon: Icons.mail_outline,
          color: AppColors.goldDark,
          title: "You're invited",
          subtitle: '${invite.clubName} invited you to this tournament. Accept to join directly.',
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: state._busy ? null : () => state._run(() => state._invites.decline(invite.id)),
                child: const Text('Decline'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: (state._busy || state._locked)
                    ? null
                    : () => state._run(() async {
                          await state._invites.accept(invite.id);
                          await state._reg.registerMember(state._tid, state._user!.name);
                        }),
                child: Text(state._locked ? 'Locked' : 'Accept'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.tournament, required this.registered, required this.isFull});

  final Tournament tournament;
  final int registered;
  final bool isFull;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final t = tournament;
    final progress = t.capacity == 0 ? 0.0 : (registered / t.capacity).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.clubName, style: AppTextStyles.caption(AppColors.goldDark)),
            const SizedBox(height: 2),
            Text(t.name, style: AppTextStyles.heading2(primaryText)),
            const SizedBox(height: 8),
            _row(Icons.golf_course_outlined, '${t.format} · ${t.courseName}', secondaryText),
            const SizedBox(height: 4),
            _row(Icons.calendar_today_outlined, '${formatShortDate(t.date)} · first tee ${t.firstTeeTime}', secondaryText),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('$registered / ${t.capacity} registered', style: AppTextStyles.bodyBold(primaryText)),
                const Spacer(),
                if (isFull)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(20)),
                    child: Text('Full', style: AppTextStyles.caption(AppColors.error)),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: AppColors.greyLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text, Color color) => Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: AppTextStyles.caption(color))),
        ],
      );
}

class _AdminPanel extends StatelessWidget {
  const _AdminPanel({required this.state});

  final _TournamentDetailPageState state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shield_outlined, size: 16, color: AppColors.goldDark),
            const SizedBox(width: 6),
            Text('Managing as ${state._role.label}', style: AppTextStyles.caption(AppColors.goldDark)),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () =>
              context.push(AppRoutes.teeSheetBuilderFor(state._tid), extra: state.widget.tournament),
          icon: const Icon(Icons.edit_calendar_outlined, size: 18),
          label: const Text('Build tee sheet'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            await context.push(AppRoutes.challengeApprovals(state._tid), extra: state.widget.tournament);
            await state._load();
          },
          icon: const Icon(Icons.verified_outlined, size: 18),
          label: Text(state._pendingChallenges > 0
              ? 'Challenge approvals (${state._pendingChallenges})'
              : 'Challenge approvals'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            await context.push(AppRoutes.invitePlayers(state._tid), extra: state.widget.tournament);
            await state._load();
          },
          icon: const Icon(Icons.person_add_alt_outlined, size: 18),
          label: const Text('Invite players'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            await context.push(AppRoutes.scorecardEntry(state._tid), extra: state.widget.tournament);
            await state._load();
          },
          icon: const Icon(Icons.scoreboard_outlined, size: 18),
          label: const Text('Enter scorecard'),
        ),
        const SizedBox(height: 20),
        Text('Pending requests · ${state._pending.length}', style: AppTextStyles.bodyBold(primaryText)),
        const SizedBox(height: 8),
        if (state._pending.isEmpty)
          Text('No requests waiting.', style: AppTextStyles.caption(secondaryText))
        else
          for (final request in state._pending)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(request.playerName, style: AppTextStyles.bodyBold(primaryText)),
                          Text('${request.homeClub} · ${formatRelativeShort(request.requestedAt)}',
                              style: AppTextStyles.caption(secondaryText)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: state._busy ? null : () => state._run(() => state._reg.reject(request.id)),
                      child: Text('Reject', style: AppTextStyles.bodyBold(AppColors.error)),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: (state._busy || state._locked)
                          ? null
                          : () => state._run(() => state._reg.approve(request.id)),
                      child: const Text('Accept'),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _MemberActions extends StatelessWidget {
  const _MemberActions({required this.state});

  final _TournamentDetailPageState state;

  @override
  Widget build(BuildContext context) {
    if (state._locked) {
      return const _StatusTile(
        icon: Icons.lock_outline,
        color: AppColors.error,
        title: 'Registration closed',
        subtitle: 'The roster locked 48 hours before tee off.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "You're a member of ${state.widget.tournament.clubName} — register straight in.",
          style: AppTextStyles.caption(AppColors.grey),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: (state._busy || state._isFull)
              ? null
              : () => state._registerWithTravelGate(context),
          child: Text(state._isFull ? 'Tournament full' : 'Register'),
        ),
      ],
    );
  }
}

class _NonMemberActions extends StatelessWidget {
  const _NonMemberActions({required this.state});

  final _TournamentDetailPageState state;

  @override
  Widget build(BuildContext context) {
    final request = state._myRequest;
    if (request != null) {
      switch (request.status) {
        case RegistrationStatus.pending:
          return const _StatusTile(
            icon: Icons.hourglass_top,
            color: AppColors.warning,
            title: 'Request pending',
            subtitle: 'A club admin will review your Request to Play.',
          );
        case RegistrationStatus.approved:
          return const _StatusTile(
            icon: Icons.check_circle_outline,
            color: AppColors.success,
            title: "You're registered",
            subtitle: 'Your request was approved.',
          );
        case RegistrationStatus.rejected:
          return const _StatusTile(
            icon: Icons.cancel_outlined,
            color: AppColors.error,
            title: 'Request declined',
            subtitle: 'The club admins declined your Request to Play.',
          );
      }
    }
    if (state._locked) {
      return const _StatusTile(
        icon: Icons.lock_outline,
        color: AppColors.error,
        title: 'Requests closed',
        subtitle: 'Requests to play closed 48 hours before tee off.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "You're not a member of ${state.widget.tournament.clubName} — your request goes to the club admins for approval.",
          style: AppTextStyles.caption(AppColors.grey),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: (state._busy || state._isFull)
              ? null
              : () => state._run(() =>
                  state._reg.requestToPlay(state._tid, state._user!.name, state._user!.homeClub)),
          child: Text(state._isFull ? 'Tournament full' : 'Request to Play'),
        ),
      ],
    );
  }
}

/// Countdown / status for the 48h roster lock and 24h pairing deadline (§2).
class _LockBanner extends StatelessWidget {
  const _LockBanner({required this.tournament});

  final Tournament tournament;

  @override
  Widget build(BuildContext context) {
    final t = tournament;
    final locked = t.isRosterLocked;
    final color = locked ? AppColors.error : AppColors.success;

    final String title;
    final String subtitle;
    if (!locked) {
      title = 'Registration open';
      subtitle = 'Roster locks in ${_humanizeDuration(t.timeUntilRosterLock)} — 48h before tee off.';
    } else if (!t.isPairingClosed) {
      title = 'Roster locked';
      subtitle =
          'Registrations and challenges are closed. Pairing preferences close in ${_humanizeDuration(t.timeUntilPairingDeadline)}.';
    } else {
      title = 'Roster & pairing locked';
      subtitle = 'Registrations, challenges, and pairing preferences are all closed.';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(locked ? Icons.lock_clock : Icons.lock_open, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyBold(color)),
                Text(subtitle, style: AppTextStyles.caption(color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact "1d 6h" / "6h 12m" / "45m" formatting for a positive duration.
String _humanizeDuration(Duration d) {
  if (d.isNegative) return 'moments';
  if (d.inDays >= 1) return '${d.inDays}d ${d.inHours % 24}h';
  if (d.inHours >= 1) return '${d.inHours}h ${d.inMinutes % 60}m';
  return '${d.inMinutes}m';
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.icon, required this.color, required this.title, required this.subtitle});

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Card(
      color: color.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyBold(primaryText)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption(secondaryText)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
