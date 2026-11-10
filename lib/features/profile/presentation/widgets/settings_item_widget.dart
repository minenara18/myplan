import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/color_tokens.dart';

/// Item pengaturan: ikon + label pendek + chevron.
class SettingsItemWidget extends StatelessWidget {
  const SettingsItemWidget({
    super.key,
    required this.icon,
    required this.label,
    this.iconLabel,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;

  /// Label Semantics untuk ikon bulat (pelengkap label utama).
  final String? iconLabel;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ColorTokens.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorTokens.moonstone.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ColorTokens.moonstone.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: ColorTokens.moonstone,
            // Ikon dekoratif di samping teks label; tetap diberi label agar
            // layar berbunyi menerangkan konteks item.
            semanticLabel: iconLabel ?? label,
          ),
        ),
        title: Text(
          label,
          maxLines: 2,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorTokens.textPrimary,
          ),
        ),
        trailing: trailing ?? const _Chevron(),
        onTap: onTap,
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.chevron_right,
      color: ColorTokens.textSecondary,
      semanticLabel: 'Buka detail',
    );
  }
}
