import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/color_tokens.dart';

/// Tingkat prioritas dibedakan oleh ikon dan bentuk; warna hanya pelengkap.
enum Priority { tinggi, sedang, rendah }

class PriorityChip extends StatelessWidget {
  const PriorityChip({
    super.key,
    required this.priority,
    this.onSelected,
  });

  final Priority priority;
  final ValueChanged<Priority>? onSelected;

  static const Map<Priority, IconData> _icons = {
    Priority.tinggi: Icons.error_outline,
    Priority.sedang: Icons.warning_amber_outlined,
    Priority.rendah: Icons.info_outline,
  };

  static const Map<Priority, Color> _colors = {
    Priority.tinggi: ColorTokens.moonstone,
    Priority.sedang: ColorTokens.moonstoneTint,
    Priority.rendah: ColorTokens.vanilla,
  };

  static const Map<Priority, String> _labels = {
    Priority.tinggi: 'Tinggi',
    Priority.sedang: 'Sedang',
    Priority.rendah: 'Rendah',
  };

  @override
  Widget build(BuildContext context) {
    final icon = _icons[priority] ?? Icons.info_outline;
    final color = _colors[priority] ?? ColorTokens.moonstone;
    final label = _labels[priority] ?? '';

    return FilterChip(
      avatar: Icon(icon, color: color, size: 16),
      label: Text(label),
      selected: false,
      onSelected: (selected) => onSelected?.call(priority),
      backgroundColor: ColorTokens.white.withValues(alpha: 0.8),
      selectedColor: color.withValues(alpha: 0.15),
      checkmarkColor: color,
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
