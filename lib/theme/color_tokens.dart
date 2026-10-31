import 'package:flutter/material.dart';

final class ColorTokens {
  ColorTokens._();

  // Primary palette dari AGENTS.md
  static const Color moonstone = Color(0xFF4C9DB0);   // primer
  static const Color moonstoneTint = Color(0xFF7DBBCA); // tint
  static const Color vanilla = Color(0xFFFFEBAF);      // aksen/terpilih
  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2D3A);  // utama
  static const Color textSecondary = Color(0xFF55636E); // sekunder (WCAG AA ≥ 4.5:1 terhadap putih)

  // Warna dari desain kartu kaca
  static const Color glassBackground = Color(0xFFFFFFFF);
  static const Color glassBorder = Color(0xFF4C9DB0); // Moonstone 20%
  static const Color glassShadow = Color(0xFF4C9DB0); // Moonstone 15% dengan opacity

  // Neutral colors untuk Material 3
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onSurface = Color(0xFF1F2D3A);
  static const Color onSurfaceVariant = Color(0xFF6B7C88);
  static const Color outline = Color(0xFFDEE2E6);

  // Error warna Material 3
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
}