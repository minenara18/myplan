import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/core/timer_state_machine.dart';
import 'package:ai_study_planner/data/repositories/focus_repository.dart';
import 'package:ai_study_planner/l10n/app_localizations.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';
import 'package:ai_study_planner/features/focus_timer/presentation/notifier/focus_timer_notifier.dart';
import 'package:ai_study_planner/features/focus_timer/presentation/widgets/timer_circle_widget.dart';
import 'package:ai_study_planner/features/focus_timer/presentation/widgets/timer_controls_widget.dart';

/// Layar Focus Timer: lingkaran besar Moonstone, kontrol, dan pilihan durasi.
/// Dibungkus ScrollView agar tidak overflow pada skala teks 2.0.
class FocusTimerScreen extends ConsumerWidget {
  const FocusTimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ChangeNotifierProvider: watch penuh agar UI ikut rebuild setiap
    // notifier.memberitahu() (detik berjalan, ganti durasi, mulai/jeda).
    final notifier = ref.watch(focusTimerNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.vertical,
            ),
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
                  '${l10n('TetapFokus')} ${notifier.duration.inMinutes} ${l10n('MinuteUnit')}',
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
                      decoration: const BoxDecoration(
                        color: ColorTokens.moonstone,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Pilihan durasi: Wrap agar aman pada skala teks 2.0
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: FocusDuration.values.map((d) {
                    final isSelected = notifier.duration == d;
                    return ChoiceChip(
                      label: Text(d.label),
                      selected: isSelected,
                      onSelected: (_) => notifier.setDuration(d),
                      backgroundColor: ColorTokens.white.withValues(alpha: 0.8),
                      selectedColor: ColorTokens.moonstone,
                      checkmarkColor: ColorTokens.textPrimary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? ColorTokens.textPrimary
                            : ColorTokens.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                // Kontrol timer
                TimerControlsWidget(
                  state: notifier.timerState,
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
