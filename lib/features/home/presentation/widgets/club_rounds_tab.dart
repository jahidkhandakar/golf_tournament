import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/location/location_state.dart';
import '../../../../core/play/play_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/info_dialog.dart';
import '../../domain/entities/club_round.dart';
import '../../domain/repositories/club_round_repository.dart';
import 'club_round_card.dart';
import 'sponsored_banner.dart';

enum _RequestStatus { none, pending, accepted, denied }

const _sentMessage =
    'Your request has been sent. The club will review it and get back to you shortly.';
const _acceptedMessage =
    'Request accepted. You are confirmed. Watch your notifications for tee times and updates.';
const _deniedMessage =
    'Not this time, this may be full, but do not count yourself out. Clubs and tournaments '
    'post new openings all the time, feel free to request again whenever you see one.';

class ClubRoundsTab extends StatefulWidget {
  const ClubRoundsTab({super.key});

  @override
  State<ClubRoundsTab> createState() => _ClubRoundsTabState();
}

class _ClubRoundsTabState extends State<ClubRoundsTab> {
  late final Future<List<ClubRound>> _future =
      GetIt.instance<ClubRoundRepository>().getClubRounds();

  // Per-round mock request lifecycle — there's no backend review process to
  // poll, so tapping "Request to Play" again on a pending request is what
  // simulates the club's decision coming back.
  final Map<String, _RequestStatus> _requestStatus = {};
  final _random = Random();

  void _showMock(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onJoinClub(ClubRound clubRound) {
    // Joining the hosting club here is the same membership used by My Clubs
    // and the challenge flow.
    GetIt.instance<PlayController>().joinClub(clubRound.clubName);
    _showMock('Joined ${clubRound.clubName}');
  }

  void _onRequestToPlay(ClubRound clubRound) {
    final current = _requestStatus[clubRound.id] ?? _RequestStatus.none;

    if (current == _RequestStatus.none) {
      setState(() => _requestStatus[clubRound.id] = _RequestStatus.pending);
      InfoDialog.show(context, title: 'Request Sent', message: _sentMessage);
      return;
    }

    if (current == _RequestStatus.pending) {
      final resolved = _random.nextBool() ? _RequestStatus.accepted : _RequestStatus.denied;
      setState(() => _requestStatus[clubRound.id] = resolved);
      InfoDialog.show(
        context,
        title: resolved == _RequestStatus.accepted ? 'Request Accepted' : 'Request Update',
        message: resolved == _RequestStatus.accepted ? _acceptedMessage : _deniedMessage,
      );
      return;
    }

    // Already resolved — re-show the same outcome rather than re-rolling it.
    InfoDialog.show(
      context,
      title: current == _RequestStatus.accepted ? 'Request Accepted' : 'Request Update',
      message: current == _RequestStatus.accepted ? _acceptedMessage : _deniedMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final radiusMiles = GetIt.instance<LocationState>().radiusMiles;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return FutureBuilder<List<ClubRound>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final allRounds = snapshot.data!;
        return ValueListenableBuilder<int>(
          valueListenable: radiusMiles,
          builder: (context, radius, _) {
            final clubRounds = allRounds.where((c) => c.distanceMiles <= radius).toList();
            return ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                const SponsoredBanner(),
                if (clubRounds.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text('No tournaments within $radius mi', style: AppTextStyles.body(secondaryText)),
                    ),
                  )
                else
                  for (final clubRound in clubRounds)
                    ClubRoundCard(
                      clubRound: clubRound,
                      onRequestToPlay: () => _onRequestToPlay(clubRound),
                      onJoinClub: () => _onJoinClub(clubRound),
                    ),
              ],
            );
          },
        );
      },
    );
  }
}
