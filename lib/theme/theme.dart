import 'package:flutter/material.dart';

import 'package:ai_study_planner/core/clock.dart';

final class AppTheme {
  AppTheme._();

  // Colors
  static const Color moonstone = Color(0xFF4C9DB0);
  static const Color moonstoneTint = Color(0xFF7DBBCA);
  static const Color vanilla = Color(0xFFFFEBAF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2D3A);
  static const Color textSecondary = Color(0xFF6B7C88);

  // Text themes
  static TextTheme textTheme(BuildContext context) => TextTheme(
        displayLarge: const TextStyle(
          fontFamily: 'DM Serif Display',
          color: textPrimary,
          fontSize: 32,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          color: textSecondary,
          fontSize: 14,
        ),
      );

  // Input decoration
  InputDecoration inputDecoration({required String label}) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: white.withValues(alpha: 0.8),
      );

  // Clock provider
  static Clock get clock => _Clock();
}

class _Clock implements Clock {
  @override
  DateTime now() => DateTime.now();
}