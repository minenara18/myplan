import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/app_theme.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';

/// Skeleton timeline saat menunggu jawaban backend AI.
/// Menghormati pengaturan reduce motion: opasitas statis bila dinonaktifkan.
class AiSkeletonTimelineWidget extends StatelessWidget {
  const AiSkeletonTimelineWidget({super.key, this.jumlah = 3});

  final int jumlah;

  @override
  Widget build(BuildContext context) {
    final disableAnimation = MediaQuery.disableAnimationsOf(context);

    return Column(
      children: [
        for (var i = 0; i < jumlah; i++)
          disableAnimation
              ? const _SkeletonKartu(transparan: false)
              : _SkeletonAnimasiKartu(urutan: i),
      ],
    );
  }
}

/// Kartu skeleton dengan denyut lembut, bergantian fase.
class _SkeletonAnimasiKartu extends StatefulWidget {
  const _SkeletonAnimasiKartu({required this.urutan});

  final int urutan;

  @override
  State<_SkeletonAnimasiKartu> createState() => _SkeletonAnimasiKartuState();
}

class _SkeletonAnimasiKartuState extends State<_SkeletonAnimasiKartu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // Durasi denyut dari token animasi tema, dua lipat agar lembut.
      duration: AppTheme.longDur * 4,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        var nilai = CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ).value;

        // Geser fase per kartu supaya bergelombang, bukan serentak.
        nilai = (nilai + (widget.urutan % 3) / 3) % 1;

        return Opacity(
          opacity: 0.45 + 0.25 * (1 - (2 * nilai - 1).abs()),
          child: child,
        );
      },
      child: const _SkeletonKartu(transparan: false),
    );
  }
}

class _SkeletonKartu extends StatelessWidget {
  const _SkeletonKartu({required bool transparan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: ColorTokens.moonstone.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ColorTokens.moonstoneTint.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: ColorTokens.moonstoneTint.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 74,
                  height: 10,
                  decoration: BoxDecoration(
                    color: ColorTokens.moonstoneTint.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
