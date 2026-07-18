import 'package:flutter/foundation.dart';

/// App-wide "home zone" the user is browsing from, plus the search radius
/// derived from it. Content across the app (Top 50, clubs, outings, nearby
/// golfers, messages) is filtered to within [radiusMiles] of this zone.
///
/// Radius is 60 mi for towns/cities but widens to 120 mi for small/rural
/// villages, where golfers are far more spread out.
///
/// A plain [ValueNotifier] rather than a full state-management layer — it's
/// the one piece of cross-screen state the app needs right now.
class LocationState {
  /// Zones offered in the onboarding + Location screen pickers.
  static const List<String> zoneOptions = [
    'Austin, TX',
    'Round Rock, TX',
    'Cedar Park, TX',
    'Dallas, TX',
    'Luckenbach, TX (village)',
  ];

  /// Zones treated as small/rural villages — they get the wider radius.
  static const Set<String> _ruralZones = {'Luckenbach, TX (village)'};

  static const int urbanRadiusMiles = 60;
  static const int ruralRadiusMiles = 120;

  static int radiusForZone(String zone) =>
      _ruralZones.contains(zone) ? ruralRadiusMiles : urbanRadiusMiles;

  final ValueNotifier<String> currentZone = ValueNotifier<String>('Austin, TX');
  final ValueNotifier<int> radiusMiles = ValueNotifier<int>(urbanRadiusMiles);

  /// Set the zone and update the radius to match. Radius is updated first so
  /// listeners on [currentZone] see a consistent radius when they rebuild.
  void setZone(String zone) {
    radiusMiles.value = radiusForZone(zone);
    currentZone.value = zone;
  }
}
