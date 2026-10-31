import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/color_tokens.dart';

/// Placeholder layar register.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add, size: 64, color: ColorTokens.moonstone),
              const SizedBox(height: 16),
              Text(
                'Daftar',
                style: TextStyle(
                  fontFamily: 'DM Serif Display',
                  fontSize: 32,
                  color: ColorTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Placeholder - layar register',
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