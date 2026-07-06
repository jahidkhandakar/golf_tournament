import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Central text style definitions, built on the fonts bundled under
/// assets/font (declared in pubspec.yaml) so the app never depends on a
/// network fetch for type — both light and dark themes pull from this
/// single scale.
class AppTextStyles {
  AppTextStyles._();

  static const String _headingFont = 'Schuyler';
  static const String _bodyFont = 'DMSans';

  static TextStyle _base({
    required String fontFamily,
    required double size,
    required FontWeight weight,
    required Color color,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle heading1(Color color) =>
      _base(fontFamily: _headingFont, size: 28, weight: FontWeight.w700, color: color);

  static TextStyle heading2(Color color) =>
      _base(fontFamily: _headingFont, size: 22, weight: FontWeight.w600, color: color);

  static TextStyle heading3(Color color) =>
      _base(fontFamily: _headingFont, size: 18, weight: FontWeight.w600, color: color);

  static TextStyle body(Color color) =>
      _base(fontFamily: _bodyFont, size: 14, weight: FontWeight.w400, color: color);

  static TextStyle bodyBold(Color color) =>
      _base(fontFamily: _bodyFont, size: 14, weight: FontWeight.w600, color: color);

  static TextStyle caption(Color color) =>
      _base(fontFamily: _bodyFont, size: 12, weight: FontWeight.w400, color: color);

  static TextStyle button = _base(
    fontFamily: _bodyFont,
    size: 16,
    weight: FontWeight.w600,
    color: AppColors.white,
  );
}
