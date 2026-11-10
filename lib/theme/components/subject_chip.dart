import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/color_tokens.dart';

/// Chip mata pelajaran dengan aksen Vanilla.
class SubjectChip extends StatelessWidget {
  const SubjectChip({
    super.key,
    required this.subject,
    this.onSelected,
  });

  final String subject;
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(subject),
      selected: false,
      onSelected: (selected) => onSelected?.call(subject),
      backgroundColor: ColorTokens.white.withValues(alpha: 0.8),
      selectedColor: ColorTokens.vanilla.withValues(alpha: 0.15),
      checkmarkColor: ColorTokens.vanilla,
      labelStyle: const TextStyle(
        color: ColorTokens.textPrimary,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
