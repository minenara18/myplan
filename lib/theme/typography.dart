import 'package:flutter/material.dart';

final class TypographyTokens {
  TypographyTokens._();

  // Font families
  static const String dmSerifDisplay = 'DM Serif Display';
  static const String inter = 'Inter';

  // Font sizes berdasarkan grid 8pt
  static const double displayLarge = 32; // 4 * 8pt
  static const double displayMedium = 28; // 3.5 * 8pt
  static const double displaySmall = 24; // 3 * 8pt
  static const double headlineLarge = 22; // 2.75 * 8pt
  static const double headlineMedium = 20; // 2.5 * 8pt
  static const double headlineSmall = 18; // 2.25 * 8pt
  static const double titleLarge = 16; // 2 * 8pt
  static const double titleMedium = 14; // 1.75 * 8pt
  static const double titleSmall = 12; // 1.5 * 8pt
  static const double bodyLarge = 16; // 2 * 8pt
  static const double bodyMedium = 14; // 1.75 * 8pt
  static const double bodySmall = 12; // 1.5 * 8pt
  static const double labelLarge = 12; // 1.5 * 8pt
  static const double labelMedium = 11; // 1.375 * 8pt
  static const double labelSmall = 10; // 1.25 * 8pt
  static const double headline = 8; // 1 * 8pt

  // Font weights
  static const FontWeight w100 = FontWeight.w100;
  static const FontWeight w200 = FontWeight.w200;
  static const FontWeight w300 = FontWeight.w300;
  static const FontWeight w400 = FontWeight.w400;
  static const FontWeight w500 = FontWeight.w500;
  static const FontWeight w600 = FontWeight.w600;
  static const FontWeight w700 = FontWeight.w700;
  static const FontWeight w800 = FontWeight.w800;
  static const FontWeight w900 = FontWeight.w900;

  // Line height - grid 8pt adaptation
  static const double displayLineHeight = 40; // displayLarge + 8pt
  static const double headlineLineHeight = 28; // headlineLarge + 8pt
  static const double titleLineHeight = 22; // titleLarge + 8pt
  static const double bodyLineHeight = 22; // bodyLarge + 8pt / 1.5
  static const double captionLineHeight = 14; // labelSmall * 1.25
}
