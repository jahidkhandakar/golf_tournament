import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/location/location_state.dart';
import '../../../../core/permission/feature.dart';
import '../../../../core/permission/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/upgrade_prompt.dart';
import '../../../profile/domain/repositories/user_profile_repository.dart';
import '../../domain/entities/looking_post.dart';
import '../../domain/repositories/looking_repository.dart';

const _formatOptions = ['Stroke Play', 'Scramble', 'Best Ball', 'Match Play', 'Skins'];

/// Gated the whole screen through [PermissionService.can] as a defense in
/// depth — the Looking tab's "Post" button already checks before pushing
/// here, but a direct deep link should still be turned away for Free tier.
class CreateLookingPostPage extends StatefulWidget {
  const CreateLookingPostPage({super.key});

  @override
  State<CreateLookingPostPage> createState() => _CreateLookingPostPageState();
}

class _CreateLookingPostPageState extends State<CreateLookingPostPage> {
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();
  final Set<String> _selectedFormats = {};
  DateTime? _startDate;
  DateTime? _endDate;
  bool _detectingLocation = false;
  String _posterName = 'You';

  @override
  void initState() {
    super.initState();
    _locationController.text = GetIt.instance<LocationState>().currentZone.value;
    GetIt.instance<UserProfileRepository>().getCurrentUser().then((user) {
      if (mounted) setState(() => _posterName = user.name);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _guardAccess());
  }

  void _guardAccess() {
    if (!GetIt.instance<PermissionService>().can(Feature.lookingToPlayPost)) {
      Navigator.of(context).pop();
      UpgradePrompt.show(context, message: 'Upgrade to post to Looking to Play.');
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _useMyLocation() async {
    setState(() => _detectingLocation = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _locationController.text = GetIt.instance<LocationState>().currentZone.value;
      _detectingLocation = false;
    });
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? _startDate ?? now),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) _endDate = null;
      } else {
        _endDate = picked;
      }
    });
  }

  void _toggleFormat(String format) {
    setState(() {
      if (_selectedFormats.contains(format)) {
        _selectedFormats.remove(format);
      } else {
        _selectedFormats.add(format);
      }
    });
  }

  Future<void> _submit() async {
    if (_locationController.text.trim().isEmpty || _startDate == null || _selectedFormats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a location, at least one date, and a format.')),
      );
      return;
    }

    final dates = [
      formatShortDate(_startDate!),
      if (_endDate != null) formatShortDate(_endDate!),
    ];

    final post = LookingPost(
      id: 'l${DateTime.now().millisecondsSinceEpoch}',
      playerName: _posterName,
      location: _locationController.text.trim(),
      availableDates: dates,
      preferredFormats: _selectedFormats.toList(),
      note: _noteController.text.trim(),
    );

    await GetIt.instance<LookingRepository>().createPost(post);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(title: const Text('Looking to Play')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Location', style: AppTextStyles.bodyBold(primaryText)),
          const SizedBox(height: 8),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              hintText: 'Where are you playing?',
              suffixIcon: _detectingLocation
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Use my location',
                      icon: const Icon(Icons.my_location),
                      onPressed: _useMyLocation,
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Available dates', style: AppTextStyles.bodyBold(primaryText)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickDate(isStart: true),
                  child: Text(_startDate == null ? 'Start date' : formatShortDate(_startDate!)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickDate(isStart: false),
                  child: Text(_endDate == null ? 'End date (optional)' : formatShortDate(_endDate!)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Preferred formats', style: AppTextStyles.bodyBold(primaryText)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final format in _formatOptions)
                FilterChip(
                  label: Text(format),
                  selected: _selectedFormats.contains(format),
                  onSelected: (_) => _toggleFormat(format),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Note', style: AppTextStyles.bodyBold(primaryText)),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Anything else players should know?'),
          ),
          const SizedBox(height: 8),
          Text(
            'Posting as $_posterName',
            style: AppTextStyles.caption(secondaryText),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _submit, child: const Text('Post')),
        ],
      ),
    );
  }
}
