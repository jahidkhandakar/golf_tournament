import 'package:flutter/material.dart';

/// App-wide light/dark mode toggle, surfaced from the Home AppBar next to
/// the location pin. Plain [ValueNotifier], same pattern as [LocationState]
/// — no need for a full state management layer for one piece of UI state.
class ThemeController {
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

  void toggle(Brightness platformBrightness) {
    final isCurrentlyDark = themeMode.value == ThemeMode.dark ||
        (themeMode.value == ThemeMode.system && platformBrightness == Brightness.dark);
    themeMode.value = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
  }
}
