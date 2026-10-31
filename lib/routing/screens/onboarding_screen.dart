import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/color_tokens.dart';

/// Placeholder layar onboarding.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.rocket_launch, size: 64, color: ColorTokens.vanilla),
              const SizedBox(height: 16),
              Text(
                'Onboarding',
                style: TextStyle(
                  fontFamily: 'DM Serif Display',
                  fontSize: 32,
                  color: ColorTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Placeholder - layar onboarding',
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