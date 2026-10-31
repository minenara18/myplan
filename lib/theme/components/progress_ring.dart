import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/color_tokens.dart';

/// Lingkaran progres sederhana.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    this.value,
    this.size,
    this.strokeWidth,
    this.color,
  });

  final double? value;
  final double? size;
  final double? strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final s = size ?? 32.0;
    final sw = strokeWidth ?? 3.0;
    final ringColor = color ?? ColorTokens.moonstone;

    return SizedBox(
      width: s,
      height: s,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: sw,
        backgroundColor: ringColor.withValues(alpha: 0.1),
        color: ringColor,
      ),
    );
  }
}