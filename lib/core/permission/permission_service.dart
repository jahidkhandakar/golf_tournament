import 'feature.dart';

/// Single source of truth for feature gating.
///
/// Stubbed to always allow access for now. Every gated feature in the app
/// should call [can] before rendering/executing — when this is wired to the
/// backend (plan tiers, entitlements, etc.) that's the only place the logic
/// needs to change.
class PermissionService {
  bool can(Feature feature) {
    return true;
  }
}
