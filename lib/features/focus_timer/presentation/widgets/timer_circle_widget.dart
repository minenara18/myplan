import 'package:flutter/material.dart';

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
    final progress = totalSeconds > 0
        ? remainingSeconds / totalSeconds
        : 0.0;

    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Trek Vanilla (lingkaran penuh)
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              color: ColorTokens.vanilla.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: ColorTokens.vanilla,
                width: 12,
              ),
            ),
          ),
          // Lingkaran progres Moonstone
          ClipOval(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                border: Border.all(
                  color: ColorTokens.moonstone,
                  width: 12,
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 210,
                  height: 210,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.transparent,
                    color: ColorTokens.moonstone,
                  ),
                ),
              ),
            ),
          ),
          // Teks waktu di tengah
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                isRunning ? 'Berjalan' : 'Siap',
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