import 'package:flutter/foundation.dart';

/// The free tier trial allowance: two independent counters that persist across
/// screens for the life of the session. Server side once the backend is wired;
/// until then this is the single source of truth so the counts survive
/// navigation instead of living inside one widget.
///
///   Home trials:   2, used when a free user creates a Small Outing inside
///                  their home zone.
///   Travel trials: 2, used when a free user joins and plays an event outside
///                  their home zone.
///
/// The counters never interact. Using a home trial does not touch the travel
/// counter and the other way around. Joining clubs, accepting invites, and
/// messaging never check either counter.
class TrialController {
  static const int limitPerCounter = 2;

  final ValueNotifier<int> homeTrialsUsed = ValueNotifier<int>(0);
  final ValueNotifier<int> travelTrialsUsed = ValueNotifier<int>(0);

  int get homeRemaining => (limitPerCounter - homeTrialsUsed.value).clamp(0, limitPerCounter);
  int get travelRemaining => (limitPerCounter - travelTrialsUsed.value).clamp(0, limitPerCounter);

  bool get canUseHomeTrial => homeTrialsUsed.value < limitPerCounter;
  bool get canUseTravelTrial => travelTrialsUsed.value < limitPerCounter;

  /// Consumes a home trial. Returns false when the counter is exhausted.
  bool useHomeTrial() {
    if (!canUseHomeTrial) return false;
    homeTrialsUsed.value = homeTrialsUsed.value + 1;
    return true;
  }

  /// Consumes a travel trial. Returns false when the counter is exhausted.
  bool useTravelTrial() {
    if (!canUseTravelTrial) return false;
    travelTrialsUsed.value = travelTrialsUsed.value + 1;
    return true;
  }
}
