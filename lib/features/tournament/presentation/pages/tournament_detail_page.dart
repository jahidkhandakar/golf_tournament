import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/permission/club_role.dart';
import '../../../../core/permission/permission_service.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/domain/repositories/user_profile_repository.dart';
import '../../domain/entities/play_request.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/repositories/registration_repository.dart';

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
  final PermissionService _permission = GetIt.instance<PermissionService>();

  late final ClubRole _role = _permission.roleInClub(widget.tournament.clubName);

  UserProfile? _user;
  int _count = 0;
  bool _registered = false;
  PlayRequest? _myRequest;
  List<PlayRequest> _pending = [];
  bool _loading = true;
  bool _busy = false;

  String get _tid => widget.tournament.id;
  bool get _isFull => _count >= widget.tournament.capacity;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = _user ?? await GetIt.instance<UserProfileRepository>().getCurrentUser();
    final count = await _reg.registeredCount(_tid);
    final pending = _role.isStaff ? await _reg.pendingRequests(_tid) : <PlayRequest>[];
    final registered = _role.isStaff ? false : await _reg.isRegistered(_tid, user.name);
    final myRequest =
        _role == ClubRole.nonMember ? await _reg.myRequest(_tid, user.name) : null;
    if (!mounted) return;
    setState(() {
      _user = user;
      _count = count;
      _pending = pending;
      _registered = registered;
      _myRequest = myRequest;
      _loading = false;
    });
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
                _roleSection(),
              ],
            ),
    );
  }

  Widget _roleSection() {
    if (_role.isStaff) return _AdminPanel(state: this);
    if (_role == ClubRole.member) return _MemberActions(state: this);
    return _NonMemberActions(state: this);
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
          onPressed: () => context.push(AppRoutes.teeSheetBuilder),
          icon: const Icon(Icons.edit_calendar_outlined, size: 18),
          label: const Text('Build tee sheet'),
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
                      onPressed: state._busy ? null : () => state._run(() => state._reg.approve(request.id)),
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
    if (state._registered) {
      return const _StatusTile(
        icon: Icons.check_circle_outline,
        color: AppColors.success,
        title: "You're registered",
        subtitle: "You're in this tournament. See the tee sheet once it's published.",
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
              : () => state._run(() => state._reg.registerMember(state._tid, state._user!.name)),
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
