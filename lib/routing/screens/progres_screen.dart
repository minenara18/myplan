import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/color_tokens.dart';

/// Placeholder layar progres.
class ProgresScreen extends StatelessWidget {
  const ProgresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 64, color: ColorTokens.moonstone),
              const SizedBox(height: 16),
              Text(
                'Progres',
                style: TextStyle(
                  fontFamily: 'DM Serif Display',
                  fontSize: 32,
                  color: ColorTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Placeholder - layar progres',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: ColorTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}