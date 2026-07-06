import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/gaggle.dart';
import '../../domain/repositories/gaggle_repository.dart';
import 'gaggle_card.dart';

class GagglesTab extends StatefulWidget {
  const GagglesTab({super.key});

  @override
  State<GagglesTab> createState() => _GagglesTabState();
}

class _GagglesTabState extends State<GagglesTab> {
  late final Future<List<Gaggle>> _future = GetIt.instance<GaggleRepository>().getGaggles();

  void _showMock(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
              onRequestToPlay: () => _showMock('Requested to play at ${gaggle.clubName} (mock)'),
              onJoinClub: () => _showMock('Joined ${gaggle.clubName} (mock)'),
            );
          },
        );
      },
    );
  }
}
