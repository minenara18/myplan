import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/color_tokens.dart';

/// Kondisi kosong dengan ilustrasi minimal dan ajakan bertindak.
class EmptyTasksWidget extends StatelessWidget {
  const EmptyTasksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: ColorTokens.moonstone.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 48,
              color: ColorTokens.moonstone,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum ada tugas',
            style: TextStyle(
              fontFamily: 'DM Serif Display',
              fontSize: 24,
              color: ColorTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambah tugas baru untuk memulai rencana belajarmu.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: ColorTokens.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}