import 'package:flutter/material.dart';

import 'package:ai_study_planner/l10n/app_localizations.dart';
import 'package:ai_study_planner/theme/app_theme.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';

/// Kolom input kaca di bawah layar AI: ikon mic (placeholder),
/// field teks konteks, dan ikon kirim untuk menyusun jadwal.
class AiInputBarWidget extends StatelessWidget {
  const AiInputBarWidget({
    super.key,
    required this.kontroler,
    required this.padaKirim,
    this.aktif = true,
  });

  final TextEditingController kontroler;
  final VoidCallback padaKirim;
  final bool aktif;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ColorTokens.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: ColorTokens.moonstone.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorTokens.moonstone.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Placeholder mic — rekaman suara hadir di langkah berikutnya.
          IconOnlyPlaceholder(
            icon: Icons.mic_none,
            label: l10n('RekamSuara'),
            onPencet: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n('SuaraSegera')),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: kontroler,
              enabled: aktif,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => padaKirim(),
              maxLines: 1,
              decoration: InputDecoration(
                hintText: l10n('KonteksAI'),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(
                fontFamily: AppTheme.inter,
                fontSize: 14,
                color: ColorTokens.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            label: 'Susun jadwal AI',
            button: true,
            child: InkWell(
              onTap: aktif ? padaKirim : null,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: aktif
                      ? ColorTokens.moonstone
                      : ColorTokens.textSecondary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  // textPrimary di atas moonstone = 4.52:1 (PASS AA),
                  // putih hanya 3.11:1.
                  color: ColorTokens.textPrimary,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ikon dengan target sentuh 48px dan Semantics.
class IconOnlyPlaceholder extends StatelessWidget {
  const IconOnlyPlaceholder({
    super.key,
    required this.icon,
    required this.label,
    required this.onPencet,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPencet;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        onTap: onPencet,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: ColorTokens.moonstone.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: ColorTokens.moonstone, size: 22),
        ),
      ),
    );
  }
}
