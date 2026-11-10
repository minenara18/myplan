import 'package:ai_study_planner/core/models/focus_record.dart';
import 'package:ai_study_planner/data/repositories/focus_repository.dart';

/// Durasi tersedia dalam menit: 25 (fokus), 5 (istirahat pendek), 15 (istirahat panjang).
enum FocusDuration { menit25, menit5, menit15 }

extension FocusDurationExt on FocusDuration {
  int get inMinutes {
    switch (this) {
      case FocusDuration.menit25:
        return 25;
      case FocusDuration.menit5:
        return 5;
      case FocusDuration.menit15:
        return 15;
    }
  }

  String get label {
    switch (this) {
      case FocusDuration.menit25:
        return '25 menit';
      case FocusDuration.menit5:
        return '5 menit';
      case FocusDuration.menit15:
        return '15 menit';
    }
  }
}

/// Status mesin state timer.
enum TimerState { idle, running, paused, completed }

/// State mesin timer — immutable.
class TimerMachineState {
  const TimerMachineState({
    this.state = TimerState.idle,
    this.duration = FocusDuration.menit25,
    this.startedAt,
    this.elapsedBeforePause = const Duration(),
    this.sessionCounter = 0,
    this.relatedTaskId,
  });

  final TimerState state;
  final FocusDuration duration;
  final DateTime? startedAt;
  final Duration elapsedBeforePause;
  final int sessionCounter;
  final String? relatedTaskId;

  /// Sisa waktu dalam detik, dihitung dari timestamp mulai (bukan per-tick).
  int get remainingSeconds {
    if (state == TimerState.idle) {
      return duration.inMinutes * 60;
    }
    if (state == TimerState.completed) {
      return 0;
    }
    if (state == TimerState.paused) {
      final remaining = duration.inMinutes * 60 - elapsedBeforePause.inSeconds;
      return remaining < 0 ? 0 : remaining;
    }
    if (startedAt == null) {
      return duration.inMinutes * 60;
    }
    final now = DateTime.now();
    final elapsed =
        elapsedBeforePause.inSeconds + now.difference(startedAt!).inSeconds;
    final remaining = duration.inMinutes * 60 - elapsed;
    return remaining < 0 ? 0 : remaining;
  }

  bool get isRunning => state == TimerState.running;
  bool get isFinished => remainingSeconds <= 0;

  TimerMachineState copyWith({
    TimerState? state,
    FocusDuration? duration,
    DateTime? startedAt,
    Duration? elapsedBeforePause,
    int? sessionCounter,
    String? relatedTaskId,
    bool clearStartedAt = false,
  }) {
    return TimerMachineState(
      state: state ?? this.state,
      duration: duration ?? this.duration,
      startedAt: clearStartedAt ? null : (startedAt ?? this.startedAt),
      elapsedBeforePause: elapsedBeforePause ?? this.elapsedBeforePause,
      sessionCounter: sessionCounter ?? this.sessionCounter,
      relatedTaskId: relatedTaskId ?? this.relatedTaskId,
    );
  }
}

/// Mesin state timer murni.
class FocusTimerMachine {
  const FocusTimerMachine();

  TimerMachineState start(TimerMachineState current, DateTime now) {
    if (current.state == TimerState.running) return current;
    return current.copyWith(
      state: TimerState.running,
      startedAt: now,
      elapsedBeforePause: current.elapsedBeforePause,
    );
  }

  TimerMachineState pause(TimerMachineState current) {
    if (current.state != TimerState.running) return current;
    final now = DateTime.now();
    final elapsed = current.startedAt == null
        ? const Duration()
        : now.difference(current.startedAt!);
    return current.copyWith(
      state: TimerState.paused,
      elapsedBeforePause: Duration(
        seconds: current.elapsedBeforePause.inSeconds + elapsed.inSeconds,
      ),
      clearStartedAt: true,
    );
  }

  TimerMachineState resume(TimerMachineState current, DateTime now) {
    if (current.state != TimerState.paused) return current;
    return current.copyWith(
      state: TimerState.running,
      startedAt: now,
    );
  }

  TimerMachineState reset(TimerMachineState current) {
    return const TimerMachineState(
      state: TimerState.idle,
      duration: FocusDuration.menit25,
      sessionCounter: 0,
    );
  }

  TimerMachineState skip(TimerMachineState current, DateTime now) {
    return current.copyWith(
      state: TimerState.completed,
      sessionCounter: current.sessionCounter + 1,
    );
  }

  TimerMachineState tick(TimerMachineState current) {
    if (current.state != TimerState.running) return current;
    if (current.isFinished) {
      return current.copyWith(
        state: TimerState.completed,
        sessionCounter: current.sessionCounter + 1,
      );
    }
    return current;
  }

  TimerMachineState changeDuration(TimerMachineState current, FocusDuration d) {
    if (current.state == TimerState.running) return current;
    return current.copyWith(duration: d, clearStartedAt: true);
  }

  TimerMachineState setTask(TimerMachineState current, String? taskId) {
    return current.copyWith(relatedTaskId: taskId);
  }
}

/// Simpan hasil sesi fokus lewat FocusRepository.
class FocusSessionResult {
  const FocusSessionResult({
    required this.durationMinutes,
    required this.completed,
    required this.taskId,
  });

  final int durationMinutes;
  final bool completed;
  final String? taskId;

  Future<void> save(FocusRepository repo) async {
    await repo.saveFocusRecord(
      FocusRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        mulai: DateTime.now().subtract(Duration(minutes: durationMinutes)),
        durasi: Duration(minutes: durationMinutes),
        taskId: taskId,
      ),
    );
  }
}
