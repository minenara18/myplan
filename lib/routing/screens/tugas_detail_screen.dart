import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/color_tokens.dart';

/// Placeholder layar detail tugas.
/// ID tugas diambil dari path parameter, bukan state.extra.
class TugasDetailScreen extends StatelessWidget {
  const TugasDetailScreen({super.key, required this.tugasId});

  final String tugasId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description, size: 64, color: ColorTokens.moonstone),
              const SizedBox(height: 16),
              Text(
                'Detail Tugas',
                style: TextStyle(
                  fontFamily: 'DM Serif Display',
                  fontSize: 32,
                  color: ColorTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ID: $tugasId',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: ColorTokens.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Placeholder - identitas lewat path param',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
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