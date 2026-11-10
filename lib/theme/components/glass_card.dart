import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/color_tokens.dart';

/// Variasi kartu kaca.
enum GlassCardVariant { hero, standard }

/// Kartu kaca. BackdropFilter hanya diterapkan pada varian hero.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    this.variant = GlassCardVariant.standard,
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.padding,
  });

  final GlassCardVariant variant;
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final isHero = variant == GlassCardVariant.hero;
    final blur = isHero ? 20.0 : 0.0;

    final card = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: ColorTokens.white.withValues(alpha: isHero ? 0.6 : 0.0),
        border: Border.all(
          color: ColorTokens.moonstone.withValues(alpha: isHero ? 0.4 : 0.2),
          width: isHero ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: isHero
            ? [
                BoxShadow(
                  color: ColorTokens.moonstone.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (!isHero) return card;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: card,
      ),
    );
  }
}
