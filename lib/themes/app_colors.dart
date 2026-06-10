import 'package:flutter/material.dart';

/// Semantic color tokens for light and dark themes.
abstract final class AppColors {
  static const Color primaryLight = Color(0xFF6750A4);
  static const Color secondaryLight = Color(0xFF625B71);
  static const Color surfaceLight = Color(0xFFFFFBFE);

  static const Color primaryDark = Color(0xFFD0BCFF);
  static const Color secondaryDark = Color(0xFFCCC2DC);
  static const Color surfaceDark = Color(0xFF1C1B1F);

  static const Color priorityLow = Color(0xFF4CAF50);
  static const Color priorityMedium = Color(0xFFFF9800);
  static const Color priorityHigh = Color(0xFFF44336);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color error = Color(0xFFD32F2F);

  static Color priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return priorityLow;
      case 'high':
        return priorityHigh;
      default:
        return priorityMedium;
    }
  }
}
