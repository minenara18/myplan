import 'package:flutter/material.dart';

import 'package:ai_study_planner/core/timer_state_machine.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';

/// Tombol kontrol: putar, jeda, lewati, ulang.
class TimerControlsWidget extends StatelessWidget {
  const TimerControlsWidget({
    super.key,
    required this.state,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onSkip,
    required this.onReset,
  });

  final TimerState state;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onSkip;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final isRunning = state == TimerState.running;
    final isPaused = state == TimerState.paused;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Jeda / Putar
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: ColorTokens.moonstone.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              isRunning ? Icons.pause : Icons.play_arrow,
              color: ColorTokens.moonstone,
              size: 28,
            ),
            tooltip: isRunning ? 'Jeda' : (isPaused ? 'Lanjutkan' : 'Mulai'),
            onPressed: isRunning ? onPause : (isPaused ? onResume : onStart),
          ),
        ),
        const SizedBox(width: 16),
        // Lewati
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: ColorTokens.vanilla.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.skip_next,
                color: ColorTokens.moonstone, size: 28),
            tooltip: 'Lewati sesi',
            onPressed: onSkip,
          ),
        ),
        const SizedBox(width: 16),
        // Ulang
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: ColorTokens.white.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh,
                color: ColorTokens.moonstone, size: 28),
            tooltip: 'Atur ulang',
            onPressed: onReset,
          ),
        ),
      ],
    );
  }
}
