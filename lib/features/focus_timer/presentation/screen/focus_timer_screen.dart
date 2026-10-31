import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/core/timer_state_machine.dart';
import 'package:ai_study_planner/data/repositories/focus_repository.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';
import 'package:ai_study_planner/features/focus_timer/presentation/notifier/focus_timer_notifier.dart';
import 'package:ai_study_planner/features/focus_timer/presentation/widgets/timer_circle_widget.dart';
import 'package:ai_study_planner/features/focus_timer/presentation/widgets/timer_controls_widget.dart';

/// Layar Focus Timer: lingkaran besar Moonstone, kontrol, dan daftar tugas terkait.
class FocusTimerScreen extends ConsumerWidget {
  const FocusTimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(focusTimerNotifierProvider.notifier);
    final state = ref.watch(focusTimerNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Judul
            Text(
              'Focus Timer',
              style: TextStyle(
                fontFamily: 'DM Serif Display',
                fontSize: 32,
                color: ColorTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tetap fokus selama ${notifier.duration.inMinutes} menit',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: ColorTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            // Lingkaran timer besar
            TimerCircleWidget(
              remainingSeconds: notifier.remainingSeconds,
              totalSeconds: notifier.duration.inMinutes * 60,
              isRunning: notifier.timerState == TimerState.running,
            ),
            const SizedBox(height: 32),
            // Titik penghitung sesi
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                notifier.sessionCounter,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: ColorTokens.moonstone,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Pilihan durasi
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: FocusDuration.values.map((d) {
                final isSelected = notifier.duration == d;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ChoiceChip(
                    label: Text(d.label),
                    selected: isSelected,
                    onSelected: (_) => notifier.setDuration(d),
                    backgroundColor: Colors.white.withValues(alpha: 0.8),
                    selectedColor: ColorTokens.moonstone,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : ColorTokens.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            // Kontrol timer
            TimerControlsWidget(
              state: state.timerState,
              onStart: notifier.start,
              onPause: notifier.pause,
              onResume: notifier.resume,
              onSkip: notifier.skip,
              onReset: notifier.reset,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// Provider FocusTimerNotifier.
final focusTimerNotifierProvider =
    ChangeNotifierProvider<FocusTimerNotifier>((ref) {
  final repo = ref.watch(focusRepositoryProvider);
  return FocusTimerNotifier(repo);
});