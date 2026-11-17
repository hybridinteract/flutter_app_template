import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand / Primary
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryLight = Color(0xFF6AB7FF);
  static const Color primaryDark = Color(0xFF005CB2);

  // Secondary / Accent
  static const Color secondary = Color(0xFF26A69A);
  static const Color secondaryLight = Color(0xFF64D8CB);
  static const Color secondaryDark = Color(0xFF00766C);

  // Neutral / Background
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);

  // Semantic
  static const Color success = Color(0xFF43A047);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFB8C00);
  static const Color info = Color(0xFF1E88E5);

  // Border & Divider
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF333333);
  static const Color dividerLight = Color(0xFFEEEEEE);
  static const Color dividerDark = Color(0xFF2C2C2C);
}
