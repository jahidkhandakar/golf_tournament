import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/play/play_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/repositories/tournament_repository.dart';

const _formatOptions = ['Stroke Play', 'Scramble', 'Best Ball', 'Match Play', 'Skins'];

/// Club Creator / sub-admin screen for creating a tournament (§1). Capacity is
/// set by the tee-box / team layout, not a flat number. Only a user who runs a
/// club (Club Creator) may reach this — otherwise an access notice is shown.
class CreateTournamentPage extends StatefulWidget {
  const CreateTournamentPage({super.key});

  @override
  State<CreateTournamentPage> createState() => _CreateTournamentPageState();
}

class _CreateTournamentPageState extends State<CreateTournamentPage> {
  final _nameController = TextEditingController();
  final _courseController = TextEditingController();
  final _emailController = TextEditingController();

  late final List<String> _myClubs =
      GetIt.instance<PlayController>().createdClubs.value.toList();

  String? _clubName;
  String _format = _formatOptions.first;
  DateTime? _date;
  TimeOfDay? _teeTime;
  int _intervalMinutes = 10;
  StartType _startType = StartType.regular;
  int _groupsCount = 10;
  int _teeBoxes = Tournament.maxTeeBoxes;
  int _teamsPerTeeBox = Tournament.maxTeamsPerTeeBox;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _clubName = _myClubs.isNotEmpty ? _myClubs.first : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _courseController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  int get _capacity => _startType == StartType.shotgun
      ? Tournament.capacityFor(_teeBoxes, _teamsPerTeeBox)
      : Tournament.capacityForGroups(_groupsCount);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _teeTime ?? const TimeOfDay(hour: 7, minute: 10),
    );
    if (picked != null) setState(() => _teeTime = picked);
  }

  Future<void> _submit() async {
    final club = _clubName;
    final messenger = ScaffoldMessenger.of(context);

    if (club == null) return;
    if (!Validators.isNotEmpty(_nameController.text) || !Validators.isNotEmpty(_courseController.text)) {
      messenger.showSnackBar(const SnackBar(content: Text('Add a tournament name and course.')));
      return;
    }
    if (_date == null || _teeTime == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Pick a date and first tee time.')));
      return;
    }
    if (_emailController.text.trim().isNotEmpty && !Validators.isValidEmail(_emailController.text)) {
      messenger.showSnackBar(const SnackBar(content: Text('Enter a valid golf course email.')));
      return;
    }

    final tournament = Tournament(
      id: 't${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      clubName: club,
      format: _format,
      courseName: _courseController.text.trim(),
      date: _date!,
      firstTeeTime: _teeTime!.format(context),
      teeOff: DateTime(_date!.year, _date!.month, _date!.day, _teeTime!.hour, _teeTime!.minute),
      intervalMinutes: _intervalMinutes,
      startType: _startType,
      groupsCount: _groupsCount,
      teeBoxes: _teeBoxes,
      teamsPerTeeBox: _teamsPerTeeBox,
      golfCourseEmail:
          _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
    );

    setState(() => _busy = true);
    await GetIt.instance<TournamentRepository>().createTournament(tournament);
    if (!mounted) return;
    setState(() => _busy = false);
    await _showCreatedDialog(tournament);
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _showCreatedDialog(Tournament t) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tournament created'),
        content: Text(
          '${t.name} is set up for ${t.clubName}.\n'
          'Capacity ${t.capacity} players · first tee ${t.firstTeeTime}.\n\n'
          'Build the tee sheet from your tournaments when you\'re ready.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Done')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    if (_clubName == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Tournament')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 40, color: secondaryText),
                const SizedBox(height: 12),
                Text('Club Creators only', style: AppTextStyles.heading3(primaryText)),
                const SizedBox(height: 6),
                Text(
                  'Only a Club Creator can create a tournament. Start a club first.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(secondaryText),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final capacityValid = _startType == StartType.shotgun
        ? Tournament.isValidLayout(_teeBoxes, _teamsPerTeeBox)
        : Tournament.isValidGroups(_groupsCount);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Tournament')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _label('Creating for', primaryText),
          const SizedBox(height: 6),
          if (_myClubs.length > 1)
            DropdownButtonFormField<String>(
              initialValue: _clubName,
              items: [for (final c in _myClubs) DropdownMenuItem(value: c, child: Text(c))],
              onChanged: (v) => setState(() => _clubName = v),
            )
          else
            Text(_clubName!, style: AppTextStyles.body(secondaryText)),
          const SizedBox(height: 20),

          _label('Tournament name', primaryText),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'e.g. Spring Club Championship'),
          ),
          const SizedBox(height: 20),

          _label('Format', primaryText),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _format,
            items: [for (final f in _formatOptions) DropdownMenuItem(value: f, child: Text(f))],
            onChanged: (v) => setState(() => _format = v ?? _format),
          ),
          const SizedBox(height: 20),

          _label('Course', primaryText),
          const SizedBox(height: 8),
          TextField(
            controller: _courseController,
            decoration: const InputDecoration(hintText: 'Course name'),
          ),
          const SizedBox(height: 20),

          _label('Date & first tee time', primaryText),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(_date == null ? 'Pick date' : formatShortDate(_date!)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.schedule, size: 16),
                  label: Text(_teeTime == null ? 'First tee' : _teeTime!.format(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _label('Start type', primaryText),
          const SizedBox(height: 8),
          SegmentedButton<StartType>(
            segments: const [
              ButtonSegment(value: StartType.regular, label: Text('Regular Start')),
              ButtonSegment(value: StartType.shotgun, label: Text('Shotgun Start')),
            ],
            selected: {_startType},
            onSelectionChanged: (s) => setState(() => _startType = s.first),
          ),
          const SizedBox(height: 8),
          Text(
            _startType == StartType.regular
                ? 'Every group starts at hole 1 at the tee interval below.'
                : 'Everyone starts at the same time on different tee boxes. The course is taken over for the round.',
            style: AppTextStyles.caption(primaryText),
          ),
          const SizedBox(height: 20),

          if (_startType == StartType.regular) ...[
            _label('Tee interval', primaryText),
            const SizedBox(height: 8),
            _Stepper(
              value: _intervalMinutes,
              min: 5,
              max: 20,
              step: 5,
              suffix: 'min between groups',
              onChanged: (v) => setState(() => _intervalMinutes = v),
            ),
            const SizedBox(height: 20),
            _label('Capacity', primaryText),
            const SizedBox(height: 8),
            _Stepper(
              value: _groupsCount,
              min: 2,
              max: 54,
              step: 1,
              suffix: 'groups (×4 players)',
              onChanged: (v) => setState(() => _groupsCount = v),
            ),
          ] else ...[
            _label('Capacity', primaryText),
            const SizedBox(height: 8),
            _Stepper(
              value: _teeBoxes,
              min: 1,
              max: Tournament.maxTeeBoxes,
              step: 1,
              suffix: 'tee boxes (holes)',
              onChanged: (v) => setState(() => _teeBoxes = v),
            ),
            const SizedBox(height: 8),
            _Stepper(
              value: _teamsPerTeeBox,
              min: 1,
              max: Tournament.maxTeamsPerTeeBox,
              step: 1,
              suffix: 'teams per tee box (×4 players)',
              onChanged: (v) => setState(() => _teamsPerTeeBox = v),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: (capacityValid ? AppColors.gold : AppColors.error).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.groups_outlined, size: 18, color: capacityValid ? AppColors.goldDark : AppColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    capacityValid
                        ? 'Capacity $_capacity players  ·  min ${Tournament.minPlayers}, max ${Tournament.maxPlayers}'
                        : 'A tournament needs ${Tournament.minPlayers}–${Tournament.maxPlayers} players (this is $_capacity). Fewer than ${Tournament.minPlayers} is a Small Outing.',
                    style: AppTextStyles.caption(capacityValid ? AppColors.goldDark : AppColors.error),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _label('Golf course email (optional)', primaryText),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'Where to send the tee sheet'),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: (_busy || !capacityValid) ? null : _submit,
            child: _busy
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Create Tournament'),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, Color color) => Text(text, style: AppTextStyles.bodyBold(color));
}

/// A compact −/+ number stepper with a trailing description.
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.suffix,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final int step;
  final String suffix;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Row(
      children: [
        IconButton.outlined(
          onPressed: value - step >= min ? () => onChanged(value - step) : null,
          icon: const Icon(Icons.remove),
          visualDensity: VisualDensity.compact,
        ),
        SizedBox(
          width: 40,
          child: Text('$value', textAlign: TextAlign.center, style: AppTextStyles.bodyBold(primaryText)),
        ),
        IconButton.outlined(
          onPressed: value + step <= max ? () => onChanged(value + step) : null,
          icon: const Icon(Icons.add),
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(suffix, style: AppTextStyles.caption(secondaryText))),
      ],
    );
  }
}
