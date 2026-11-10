import 'package:flutter/material.dart';

import 'package:ai_study_planner/l10n/app_localizations.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';

/// Lingkaran besar Moonstone dengan trek Vanilla.
class TimerCircleWidget extends StatelessWidget {
  const TimerCircleWidget({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isRunning,
  });

  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;

    // Lingkaran tumbuh mengikuti skala teks: angka besar "25:00" dengan
    // huruf 48 selalu muat di dalam lingkaran, tanpa potongan teks,
    // pada skala teks besar (mis. 2.0). Batas atas mengikuti batas skala.
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final dialSize = 260.0 * textScale;
    final dialBorder = 12.0 * textScale;
    final dialInner = 210.0 * textScale;

    return SizedBox(
      width: dialSize,
      height: dialSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Trek Vanilla (lingkaran penuh)
          Container(
            width: dialSize,
            height: dialSize,
            decoration: BoxDecoration(
              color: ColorTokens.vanilla.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: ColorTokens.vanilla,
                width: dialBorder,
              ),
            ),
          ),
          // Lingkaran progres Moonstone
          ClipOval(
            child: Container(
              width: dialSize,
              height: dialSize,
              decoration: BoxDecoration(
                color: ColorTokens.white.withValues(alpha: 0.6),
                border: Border.all(
                  color: ColorTokens.moonstone,
                  width: dialBorder,
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: dialInner,
                  height: dialInner,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: ColorTokens.transparent,
                    color: ColorTokens.moonstone,
                  ),
                ),
              ),
            ),
          ),
          // Teks waktu di tengah; tinggi kolom mengikuti
          // lingkaran yang ikut tumbuh pada skala teks besar.
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontFamily: 'DM Serif Display',
                  fontSize: 48,
                  fontWeight: FontWeight.w400,
                  color: ColorTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isRunning ? l10n('Berjalan') : l10n('Siap'),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: ColorTokens.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
