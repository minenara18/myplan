import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/color_tokens.dart';

/// Placeholder layar beranda.
class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home, size: 64, color: ColorTokens.moonstone),
              const SizedBox(height: 16),
              Text(
                'Beranda',
                style: TextStyle(
                  fontFamily: 'DM Serif Display',
                  fontSize: 32,
                  color: ColorTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Placeholder - layar beranda',
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