import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/permission/club_role.dart';
import '../../../../core/permission/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../tournament/domain/entities/tournament.dart';
import '../../domain/entities/player_slot.dart';
import '../../domain/entities/tee_sheet.dart';
import '../../domain/repositories/tee_sheet_repository.dart';
import '../widgets/roster_player_chip.dart';
import '../widgets/tee_group_card.dart';

/// Club Creator / sub-admin screen for building a tournament's tee sheet (§5):
/// a roster panel of unplaced players up top, the tee-time groups below, and a
/// Save Draft / Publish / Email-to-Course action bar.
///
/// Admin-only: gated on the user's [ClubRole] in the tournament's club via
/// [PermissionService]. Members and non-members see a read-only notice instead.
class TeeSheetBuilderPage extends StatefulWidget {
  const TeeSheetBuilderPage({super.key, this.tournament});

  /// The tournament whose sheet is being built. Null only for the standalone
  /// drawer shortcut, which defaults to the Riverbend Championship.
  final Tournament? tournament;

  @override
  State<TeeSheetBuilderPage> createState() => _TeeSheetBuilderPageState();
}

class _TeeSheetBuilderPageState extends State<TeeSheetBuilderPage> {
  final TeeSheetRepository _repo = GetIt.instance<TeeSheetRepository>();
  final PermissionService _permission = GetIt.instance<PermissionService>();
  TeeSheet? _sheet;
  bool _busy = false;

  String get _tid => widget.tournament?.id ?? 't_riverbend';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sheet = await _repo.getTeeSheet(_tid);
    if (mounted) setState(() => _sheet = sheet);
  }

  Future<void> _run(Future<TeeSheet> Function() action, {String? doneMessage}) async {
    setState(() => _busy = true);
    final sheet = await action();
    if (!mounted) return;
    setState(() {
      _sheet = sheet;
      _busy = false;
    });
    if (doneMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(doneMessage)));
    }
  }

  void _assign(int group, SlotPosition position, String playerId) => _run(
        () => _repo.assignPlayer(
            tournamentId: _tid, playerId: playerId, groupNumber: group, position: position),
      );

  void _unassign(int group, SlotPosition position) => _run(
        () => _repo.unassignSlot(tournamentId: _tid, groupNumber: group, position: position),
      );

  Future<void> _addGuest(int group, SlotPosition position) async {
    final name = await _promptGuestName();
    if (name == null || name.trim().isEmpty) return;
    _run(
      () => _repo.addGuest(
          tournamentId: _tid, groupNumber: group, position: position, guestName: name.trim()),
    );
  }

  Future<String?> _promptGuestName() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Guest'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Guest name from the course'),
          onSubmitted: (v) => Navigator.of(context).pop(v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(controller.text), child: const Text('Add')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sheet = _sheet;
    final role = sheet == null ? null : _permission.roleInClub(sheet.clubName);
    final canManage = role?.canEditTeeSheet ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tee Sheet Builder'),
        actions: [
          if (sheet != null && canManage)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(child: _StatusChip(status: sheet.status)),
            ),
        ],
      ),
      body: sheet == null
          ? const Center(child: CircularProgressIndicator())
          : !canManage
              ? _AccessDenied(role: role!)
              : Column(
                  children: [
                    _EventHeader(sheet: sheet, role: role!),
                    _RosterPanel(sheet: sheet),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(top: 4, bottom: 12),
                        children: [
                          for (final group in sheet.groups)
                            TeeGroupCard(
                              group: group,
                              onAssign: _assign,
                              onUnassign: _unassign,
                              onAddGuest: _addGuest,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: (sheet == null || !canManage)
          ? null
          : _ActionBar(
              busy: _busy,
              isPublished: sheet.isPublished,
              onSaveDraft: () => _run(() => _repo.saveDraft(sheet), doneMessage: 'Draft saved'),
              onPublish: () => _run(() => _repo.publish(_tid), doneMessage: 'Tee sheet published to players'),
              onEmail: () => _run(
                () async {
                  await _repo.emailToCourse(_tid);
                  return sheet;
                },
                doneMessage: sheet.golfCourseEmail == null
                    ? 'No course email on file'
                    : 'Emailed to ${sheet.golfCourseEmail}',
              ),
            ),
    );
  }
}

class _EventHeader extends StatelessWidget {
  const _EventHeader({required this.sheet, required this.role});

  final TeeSheet sheet;
  final ClubRole role;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(sheet.tournamentName, style: AppTextStyles.heading3(primaryText))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Editing as ${role.label}', style: AppTextStyles.caption(AppColors.goldDark)),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text('${sheet.clubName} · ${sheet.courseName} · ${sheet.date}', style: AppTextStyles.caption(secondaryText)),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: secondaryText),
              const SizedBox(width: 4),
              Text(
                'First tee ${sheet.firstTeeTime} · ${sheet.intervalMinutes} min interval · ${sheet.assignedCount}/${sheet.slotCapacity} placed',
                style: AppTextStyles.caption(secondaryText),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Pairing preferences stay open until 24h before tee time.',
            style: AppTextStyles.caption(AppColors.goldDark),
          ),
        ],
      ),
    );
  }
}

class _RosterPanel extends StatelessWidget {
  const _RosterPanel({required this.sheet});

  final TeeSheet sheet;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            children: [
              Icon(Icons.groups_outlined, size: 16, color: secondaryText),
              const SizedBox(width: 6),
              Text('Roster · ${sheet.roster.length} unassigned', style: AppTextStyles.caption(secondaryText)),
              const Spacer(),
              Text('drag into a slot →', style: AppTextStyles.caption(secondaryText)),
            ],
          ),
        ),
        SizedBox(
          height: 60,
          child: sheet.roster.isEmpty
              ? Center(child: Text('All players placed', style: AppTextStyles.caption(secondaryText)))
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sheet.roster.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => Center(child: RosterPlayerChip(player: sheet.roster[index])),
                ),
        ),
      ],
    );
  }
}

/// Shown when a non-admin (member / non-member) reaches the builder — only a
/// club's Creator or sub-admins may edit its tee sheet (§4).
class _AccessDenied extends StatelessWidget {
  const _AccessDenied({required this.role});

  final ClubRole role;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 40, color: secondaryText),
            const SizedBox(height: 12),
            Text('Admins only', style: AppTextStyles.heading3(primaryText)),
            const SizedBox(height: 6),
            Text(
              "Only a club's Creator or sub-admins can build the tee sheet. "
              'Your role here is ${role.label}.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body(secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final TeeSheetStatus status;

  @override
  Widget build(BuildContext context) {
    final published = status == TeeSheetStatus.published;
    final color = published ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(20)),
      child: Text(
        published ? 'Published' : 'Draft',
        style: AppTextStyles.caption(color).copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.busy,
    required this.isPublished,
    required this.onSaveDraft,
    required this.onPublish,
    required this.onEmail,
  });

  final bool busy;
  final bool isPublished;
  final VoidCallback onSaveDraft;
  final VoidCallback onPublish;
  final VoidCallback onEmail;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            IconButton.outlined(
              onPressed: busy ? null : onEmail,
              icon: const Icon(Icons.mail_outline),
              tooltip: 'Email to course',
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: busy ? null : onSaveDraft,
                child: const Text('Save Draft'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: busy ? null : onPublish,
                child: Text(isPublished ? 'Republish' : 'Publish'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
