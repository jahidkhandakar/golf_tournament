import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/widgets/info_dialog.dart';
import '../../domain/entities/gaggle.dart';
import '../../domain/repositories/gaggle_repository.dart';
import 'gaggle_card.dart';

enum _RequestStatus { none, pending, accepted, denied }

const _sentMessage =
    'Your request has been sent. The club will review it and get back to you shortly.';
const _acceptedMessage =
    'Request accepted. You are confirmed. Watch your notifications for tee times and updates.';
const _deniedMessage =
    'Not this time, this may be full, but do not count yourself out. Clubs and tournaments '
    'post new openings all the time, feel free to request again whenever you see one.';

class GagglesTab extends StatefulWidget {
  const GagglesTab({super.key});

  @override
  State<GagglesTab> createState() => _GagglesTabState();
}

class _GagglesTabState extends State<GagglesTab> {
  late final Future<List<Gaggle>> _future = GetIt.instance<GaggleRepository>().getGaggles();

  // Per-gaggle mock request lifecycle — there's no backend review process to
  // poll, so tapping "Request to Play" again on a pending request is what
  // simulates the club's decision coming back.
  final Map<String, _RequestStatus> _requestStatus = {};
  final _random = Random();

  void _showMock(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onRequestToPlay(Gaggle gaggle) {
    final current = _requestStatus[gaggle.id] ?? _RequestStatus.none;

    if (current == _RequestStatus.none) {
      setState(() => _requestStatus[gaggle.id] = _RequestStatus.pending);
      InfoDialog.show(context, title: 'Request Sent', message: _sentMessage);
      return;
    }

    if (current == _RequestStatus.pending) {
      final resolved = _random.nextBool() ? _RequestStatus.accepted : _RequestStatus.denied;
      setState(() => _requestStatus[gaggle.id] = resolved);
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
    return FutureBuilder<List<Gaggle>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final gaggles = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: gaggles.length,
          itemBuilder: (context, index) {
            final gaggle = gaggles[index];
            return GaggleCard(
              gaggle: gaggle,
              onRequestToPlay: () => _onRequestToPlay(gaggle),
              onJoinClub: () => _showMock('Joined ${gaggle.clubName} (mock)'),
            );
          },
        );
      },
    );
  }
}
