import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/color_tokens.dart';

/// Tombol ikon-only dengan target sentuh minimal 48px.
/// Wajib punya label Semantics.
class IconOnlyButton extends StatelessWidget {
  const IconOnlyButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    this.size = 24,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? ColorTokens.moonstone;

    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: size,
          ),
        ),
      ),
    );
  }
}