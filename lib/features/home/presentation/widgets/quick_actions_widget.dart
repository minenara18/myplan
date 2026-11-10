import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_study_planner/l10n/app_localizations.dart';
import 'package:ai_study_planner/routing/routes.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';

/// Aksi cepat 4 ikon: tambah tugas, rencana AI, timer, ringkas materi.
/// Memakai Wrap dua kolom (bukan GridView dengan aspectRatio tetap) agar
/// label tetap muat pada skala teks besar tanpa overflow.
/// Navigasi memakai rute dari routing/routes.dart.
class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, kons) {
        final lebarTile = (kons.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ActionTile(
              lebar: lebarTile,
              icon: Icons.add_task,
              label: l10n('AddTaskQuick'),
              color: ColorTokens.moonstone,
              onTap: () => context.push(AppRoutes.tugasBaru),
            ),
            _ActionTile(
              lebar: lebarTile,
              icon: Icons.smart_toy,
              label: l10n('AIPlanQuick'),
              color: ColorTokens.vanilla,
              onTap: () => context.go(AppRoutes.ai),
            ),
            _ActionTile(
              lebar: lebarTile,
              icon: Icons.timer,
              label: l10n('TimerQuick'),
              color: ColorTokens.moonstoneTint,
              onTap: () => context.push(AppRoutes.fokus),
            ),
            _ActionTile(
              lebar: lebarTile,
              icon: Icons.note,
              label: l10n('RingkasQuick'),
              color: ColorTokens.moonstone,
              onTap: () => context.push(AppRoutes.ringkasMateri),
            ),
          ],
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.lebar,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final double lebar;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: lebar,
      child: Material(
        color: ColorTokens.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 28, color: color, semanticLabel: label),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ColorTokens.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
