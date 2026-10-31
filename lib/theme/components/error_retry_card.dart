import 'package:flutter/material.dart';

import 'package:ai_study_planner/l10n/app_localizations.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';

/// Kartu kegagalan dengan pesan dan tombol coba lagi.
/// Dipakai semua layar saat data gagal dimuat.
class ErrorRetryCard extends StatelessWidget {
  const ErrorRetryCard({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon = Icons.cloud_off,
  });

  final String message;
  final VoidCallback onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ColorTokens.moonstone.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: ColorTokens.moonstone),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: ColorTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: l10n('CobaLagi'),
              button: true,
              child: InkWell(
                onTap: onRetry,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  height: 48,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: ColorTokens.moonstone,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    l10n('CobaLagi'),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
