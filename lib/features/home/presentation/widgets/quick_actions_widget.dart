import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_study_planner/routing/routes.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';

/// Grid aksi cepat 4 ikon: tambah tugas, rencana AI, timer, catatan.
/// Navigasi memakai rute dari routing/routes.dart.
class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _ActionTile(
          icon: Icons.add_task,
          label: 'Tambah Tugas',
          color: ColorTokens.moonstone,
          onTap: () => context.push(AppRoutes.tugasBaru),
        ),
        _ActionTile(
          icon: Icons.smart_toy,
          label: 'Rencana AI',
          color: ColorTokens.vanilla,
          onTap: () => context.go(AppRoutes.ai),
        ),
        _ActionTile(
          icon: Icons.timer,
          label: 'Timer',
          color: ColorTokens.moonstoneTint,
          onTap: () => context.push(AppRoutes.fokus),
        ),
        _ActionTile(
          icon: Icons.note,
          label: 'Catatan',
          color: ColorTokens.moonstone,
          onTap: () => context.push(AppRoutes.ringkasMateri),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: color),
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
    );
  }
}