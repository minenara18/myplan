import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/color_tokens.dart';

/// Status tugas: belum, berjalan, selesai.
enum Status { belum, berjalan, selesai }

class StatusIcon extends StatelessWidget {
  const StatusIcon({
    super.key,
    required this.status,
  });

  final Status status;

  static const Map<Status, IconData> _icons = {
    Status.belum: Icons.schedule,
    Status.berjalan: Icons.play_arrow,
    Status.selesai: Icons.check_circle,
  };

  static const Map<Status, Color> _colors = {
    Status.belum: ColorTokens.moonstone,
    Status.berjalan: ColorTokens.moonstoneTint,
    Status.selesai: ColorTokens.vanilla,
  };

  static const Map<Status, String> _labels = {
    Status.belum: 'Belum',
    Status.berjalan: 'Berjalan',
    Status.selesai: 'Selesai',
  };

  @override
  Widget build(BuildContext context) {
    final icon = _icons[status] ?? Icons.schedule;
    final color = _colors[status] ?? ColorTokens.moonstone;
    final label = _labels[status] ?? '';

    return Semantics(
      label: label,
      child: Icon(
        icon,
        color: color,
        size: 20,
        semanticLabel: label,
      ),
    );
  }
}