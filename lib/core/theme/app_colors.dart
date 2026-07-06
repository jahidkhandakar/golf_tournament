import 'package:flutter/material.dart';

/// Central color palette for GGW Connect.
/// Brand accent is #F1BD19 (gold/yellow) across both light and dark themes,
/// and is also the AppBar background color everywhere.
class AppColors {
  AppColors._();

  // Brand
  static const Color gold = Color(0xFFF1BD19);
  static const Color goldDark = Color(0xFFCA9E0C);
  static const Color goldLight = Color(0xFFF6D465);

  // Neutrals
  static const Color black = Color(0xFF1A1A1A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE0E0E0);

  // Light theme surfaces
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF6B6B6B);

  // Dark theme surfaces
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  // Semantic
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
}
