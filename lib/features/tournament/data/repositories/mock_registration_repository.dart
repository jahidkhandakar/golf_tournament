import '../../domain/entities/play_request.dart';
import '../../domain/repositories/registration_repository.dart';

/// In-memory registration store. Seeded so each role path is demoable against
/// the mock tournaments: registered counts match the tournament seeds, and the
/// Riverbend tournament has a couple of pending non-member requests for the
/// Club Creator (Jahid) to accept/reject.
class MockRegistrationRepository implements RegistrationRepository {
  final Map<String, int> _counts = {
    't_riverbend': 40,
    't_oakmont': 12,
    't_pinevalley': 30,
  };

  // "tournamentId|playerName". Seeded with a representative set of registered
  // players per tournament so the tee sheet has a real roster to place.
  final Set<String> _registered = {
    't_riverbend|Jahid', 't_riverbend|Marcus Thompson', 't_riverbend|Priya Kapoor',
    't_riverbend|Erin Walsh', 't_riverbend|Dana Reyes', 't_riverbend|Sam Ortiz',
    't_riverbend|Jordan Blake', 't_riverbend|Casey Nguyen',
    't_oakmont|Erin Walsh', 't_oakmont|Dana Reyes', 't_oakmont|Jordan Blake', 't_oakmont|Casey Nguyen',
    't_pinevalley|Devon Lee', 't_pinevalley|Sam Ortiz', 't_pinevalley|Riley Foster',
    't_riverbend_twilight|Marcus Thompson', 't_riverbend_twilight|Priya Kapoor',
    't_riverbend_twilight|Sam Ortiz', 't_riverbend_twilight|Erin Walsh',
    't_oakmont_medal|Erin Walsh', 't_oakmont_medal|Dana Reyes', 't_oakmont_medal|Jordan Blake',
  };

  final List<PlayRequest> _requests = [
    PlayRequest(
      id: 'r1',
      tournamentId: 't_riverbend',
      playerName: 'Taylor Brooks',
      homeClub: 'Lakeside Links',
      status: RegistrationStatus.pending,
      requestedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    PlayRequest(
      id: 'r2',
      tournamentId: 't_riverbend',
      playerName: 'Casey Nguyen',
      homeClub: 'Lakeside Links',
      status: RegistrationStatus.pending,
      requestedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];

  String _key(String tournamentId, String playerName) => '$tournamentId|$playerName';

  Future<T> _delayed<T>(T value) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return value;
  }

  @override
  Future<int> registeredCount(String tournamentId) => _delayed(_counts[tournamentId] ?? 0);

  @override
  Future<List<String>> registeredPlayers(String tournamentId) {
    final prefix = '$tournamentId|';
    return _delayed(_registered
        .where((k) => k.startsWith(prefix))
        .map((k) => k.substring(prefix.length))
        .toList());
  }

  @override
  Future<bool> isRegistered(String tournamentId, String playerName) =>
      _delayed(_registered.contains(_key(tournamentId, playerName)));

  @override
  Future<void> registerMember(String tournamentId, String playerName) {
    if (_registered.add(_key(tournamentId, playerName))) {
      _counts[tournamentId] = (_counts[tournamentId] ?? 0) + 1;
    }
    return _delayed(null);
  }

  @override
  Future<PlayRequest?> myRequest(String tournamentId, String playerName) {
    PlayRequest? found;
    for (final r in _requests) {
      if (r.tournamentId == tournamentId && r.playerName == playerName) found = r;
    }
    return _delayed(found);
  }

  @override
  Future<PlayRequest> requestToPlay(String tournamentId, String playerName, String homeClub) {
    final request = PlayRequest(
      id: 'r${DateTime.now().millisecondsSinceEpoch}',
      tournamentId: tournamentId,
      playerName: playerName,
      homeClub: homeClub,
      status: RegistrationStatus.pending,
      requestedAt: DateTime.now(),
    );
    _requests.add(request);
    return _delayed(request);
  }

  @override
  Future<List<PlayRequest>> pendingRequests(String tournamentId) => _delayed(
        _requests
            .where((r) => r.tournamentId == tournamentId && r.status == RegistrationStatus.pending)
            .toList(),
      );

  @override
  Future<void> approve(String requestId) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index >= 0) {
      final request = _requests[index];
      _requests[index] = request.copyWith(status: RegistrationStatus.approved);
      if (_registered.add(_key(request.tournamentId, request.playerName))) {
        _counts[request.tournamentId] = (_counts[request.tournamentId] ?? 0) + 1;
      }
    }
    return _delayed(null);
  }

  @override
  Future<void> reject(String requestId) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index >= 0) {
      _requests[index] = _requests[index].copyWith(status: RegistrationStatus.rejected);
    }
    return _delayed(null);
  }
}
