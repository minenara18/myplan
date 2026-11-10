import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/color_tokens.dart';

/// 2-3 lingkaran Moonstone/Vanilla yang diburamkan di latar putih.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, this.circleCount = 3});

  final int circleCount;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _AmbientPainter(circleCount: circleCount),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  _AmbientPainter({required this.circleCount});

  final int circleCount;

  @override
  void paint(Canvas canvas, Size size) {
    // Latar putih
    final bgPaint = Paint()..color = ColorTokens.white;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Lingkaran Moonstone & Vanilla yang diburamkan
    final positions = <Offset>[];
    for (int i = 0; i < circleCount; i++) {
      positions.add(Offset(
        size.width * (0.25 + i * 0.25),
        size.height * (0.25 + i * 0.25),
      ));
    }

    for (int i = 0; i < positions.length; i++) {
      final color = i.isEven
          ? ColorTokens.moonstone.withValues(alpha: 0.35)
          : ColorTokens.vanilla.withValues(alpha: 0.30);
      final paint = Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

      canvas.drawCircle(positions[i], size.width * 0.20, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter old) => false;
}
