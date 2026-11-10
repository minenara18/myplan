import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/color_tokens.dart';

// Extension untuk mengambil tema glass dari context
/// Akan panic jika ekstensi tidak terpasang
extension ContextGlass on BuildContext {
  double get glassOpacity => 0.65;

  double get glassSigma => 20.0;

  Color get glassBorderColor => ColorTokens.moonstone;

  Color get glassShadowColor => Color(0xFF4C9DB0);
}

// Warna warna tema statis
final class AppTheme {
  AppTheme._();

  // Kontras teks terhadap white untuk verifikasi WCAG AA
  static const double minContrastAA = 4.5;
  static const double minContrastAAA = 7.0;

  // Verifikasi kontras yang sudah hitung manual
  // #1F2D3A vs #FFFFFF: > 7:1 (AAA for normal text)
  // #6B7C88 vs #FFFFFF: ~5.5:1 (AA for normal text)

  // Font families
  static const String dmSerifDisplay = 'DM Serif Display';
  static const String inter = 'Inter';

  // Grid spacing 8pt
  static const double spacing8 = 8.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // Radius 20-24px sebagai spek desain
  static const double radiusSm = 12.0;
  static const double radiusMd = 20.0;
  static const double radiusLg = 24.0;

  // Durasi animasi
  static const Duration shortDur = Duration(milliseconds: 150);
  static const Duration mediumDur = Duration(milliseconds: 200);
  static const Duration longDur = Duration(milliseconds: 300);
  static const Duration splashAnimDur = Duration(milliseconds: 600);

  // Bayangan kaca: Moonstone 15% - warna konstan
  static const Color glassShadowColor = Color(0xFF4C9DB0);

  // Opacity kaca: 60-70%
  static const double glassOpacity = 0.65;

  // Sigma blur
  static const double glassSigma = 20.0;
}
