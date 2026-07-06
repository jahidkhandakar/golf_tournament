import 'package:flutter/foundation.dart';

/// App-wide "home zone" the user is browsing from. Set during the Location
/// Permission step of sign-up onboarding, and changeable afterward from the
/// Location screen (gated by [PermissionService] for free-tier users).
///
/// Defaults to a mock zone rather than "Not set" since the Login path skips
/// location permission entirely and goes straight to the shell.
///
/// This is intentionally a plain [ValueNotifier] rather than a full state
/// management layer — it's the one piece of cross-screen state the app
/// needs right now (Home's zone line + the Location screen both read it).
class LocationState {
  final ValueNotifier<String> currentZone = ValueNotifier<String>('Austin, TX');
  final ValueNotifier<int> radiusMiles = ValueNotifier<int>(60);
}
