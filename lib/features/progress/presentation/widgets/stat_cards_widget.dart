import 'package:flutter/material.dart';

import 'package:ai_study_planner/core/aggregation.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';

/// Tiga kartu kaca statistik: jam belajar, tugas selesai, streak.
class StatCardsWidget extends StatelessWidget {
  const StatCardsWidget({super.key, this.stats});

  final ProgressStats? stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.access_time,
            label: 'Jam Belajar',
            value: '${(stats?.totalStudyMinutes ?? 0) ~/ 60} jam',
            color: ColorTokens.moonstone,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle,
            label: 'Tugas Selesai',
            value: '${stats?.completedTasks ?? 0} / ${stats?.totalTasks ?? 0}',
            color: ColorTokens.moonstoneTint,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department,
            label: 'Streak',
            value: '${stats?.streak ?? 0} hari',
            color: ColorTokens.vanilla,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'DM Serif Display',
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: ColorTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: ColorTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}