import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/color_tokens.dart';

/// Satu slide onboarding dengan ilustrasi minimal dari bentuk dan ikon.
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ilustrasi minimal: lingkaran dengan ikon di tengah
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.4),
              width: 2,
            ),
          ),
          child: Icon(icon, size: 56, color: color),
        ),
        const SizedBox(height: 32),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'DM Serif Display',
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: ColorTokens.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          description,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: ColorTokens.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}