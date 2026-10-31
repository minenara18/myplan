import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/color_tokens.dart';

/// Placeholder layar profil.
class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 64, color: ColorTokens.moonstoneTint),
              const SizedBox(height: 16),
              Text(
                'Profil',
                style: TextStyle(
                  fontFamily: 'DM Serif Display',
                  fontSize: 32,
                  color: ColorTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Placeholder - layar profil',
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