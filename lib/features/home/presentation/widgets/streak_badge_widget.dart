import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/color_tokens.dart';

/// Lencana streak berikon api.
class StreakBadgeWidget extends StatelessWidget {
  const StreakBadgeWidget({super.key, required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: ColorTokens.vanilla.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorTokens.vanilla,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, size: 20, color: ColorTokens.vanilla),
          const SizedBox(width: 8),
          Text(
            '$streak hari',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ColorTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}