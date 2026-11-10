import 'package:flutter/material.dart';

import 'package:ai_study_planner/l10n/app_localizations.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';

/// Tombol Google berupa ikon (belum berfungsi).
class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: ColorTokens.googleBlue,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.g_mobiledata,
            size: 16, color: ColorTokens.white, semanticLabel: 'Google'),
      ),
      label: Text(
        l10n('LanjutDenganGoogle'),
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: ColorTokens.textPrimary,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        side: const BorderSide(color: ColorTokens.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
