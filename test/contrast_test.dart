import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';

/// Test kontras teks utama (#1F2D3A) dan sekunder (#6B7C88) terhadap putih (#FFFFFF)
/// Harus memenuhi WCAG AA: minimal 4.5:1 untuk teks normal, 3:1 untuk teks besar
void main() {
  group('WCAG Contrast Tests', () {
    test('Primary text #1F2D3A memiliki kontras > 7:1 terhadap putih',
        () {
      final Color textColor = Color(0xFF1F2D3A);
      final Color bgColor = Color(0xFFFFFFFF);

      // Gunakan metode bawaan Color.computeLuminance()
      final double textLuminance = textColor.computeLuminance();
      final double bgLuminance = bgColor.computeLuminance();

      // Kontras ratio: (L_white + 0.05) / (L_text + 0.05)
      final double contrastRatio = (bgLuminance + 0.05) / (textLuminance + 0.05);

      // Harus di atas 4.5:1 untuk WCAG AA normal text
      expect(contrastRatio, greaterThanOrEqualTo(4.5));
      // Primary text harus di atas 7:1
      expect(contrastRatio, greaterThanOrEqualTo(7.0));
    });

    test('Secondary text #55636E memiliki kontras > 4.5:1 terhadap putih',
        () {
      final Color textColor = Color(0xFF55636E);
      final Color bgColor = Color(0xFFFFFFFF);

      final double textLuminance = textColor.computeLuminance();
      final double bgLuminance = bgColor.computeLuminance();

      final double contrastRatio = (bgLuminance + 0.05) / (textLuminance + 0.05);

      // Harus di atas 4.5:1 untuk WCAG AA normal text
      expect(contrastRatio, greaterThanOrEqualTo(4.5));
    });

    test('Teks primer pada light mode memiliki kontras yang memadai',
        () {
      final Color textColor = ColorTokens.textPrimary;
      final Color bgColor = Colors.white;

      final contrast = _contrast(textColor, bgColor);
      expect(contrast, greaterThanOrEqualTo(4.5));
    });

    test('Teks sekunder pada light mode memiliki kontras yang memadai',
        () {
      final Color textColor = ColorTokens.textSecondary;
      final Color bgColor = Colors.white;

      final contrast = _contrast(textColor, bgColor);
      expect(contrast, greaterThanOrEqualTo(4.5));
    });
  });
}

/// Menghitung kontras ratio antara dua warna
double _contrast(Color lightColor, Color darkColor) {
  final double lumLight = lightColor.computeLuminance();
  final double lumDark = darkColor.computeLuminance();

  // Pastikan lightColor adalah yang lebih terang
  final double lightLum = lumLight > lumDark ? lumLight : lumDark;
  final double darkLum = lumLight > lumDark ? lumDark : lumLight;

  return (lightLum + 0.05) / (darkLum + 0.05);
}