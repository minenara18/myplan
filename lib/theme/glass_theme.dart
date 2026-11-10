import 'package:flutter/material.dart';

/// Extension untuk Glassmorphism theming
extension GlassThemeExtension on ThemeData {
  /// Opacity kaca (60-70% sebagai spesifikasi)
  double get glassOpacity => 0.65;

  /// Sigma blur untuk backdrop filter
  double get glassSigma => 20.0;

  /// Warna border kaca - Moonstone 20%
  Color get glassBorderColor => Color(0xFF4C9DB0);

  /// Bayangan kaca - Moonstone 15%
  Color get glassShadowColor => Color.fromARGB(
        (255 * 0.15).toInt(),
        76,
        157,
        176,
      );

  /// Border radius standar kartu kaca
  BorderRadius get glassRadius => BorderRadius.circular(24);

  /// Radius kecil untuk komponen
  BorderRadius get smallRadius => BorderRadius.circular(12);

  /// Radius minimal untuk input
  BorderRadius get inputRadius => BorderRadius.circular(12);
}
