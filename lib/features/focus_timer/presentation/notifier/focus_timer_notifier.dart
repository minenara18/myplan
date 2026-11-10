import 'package:flutter/material.dart';

import 'package:ai_study_planner/core/clock.dart';
import 'package:ai_study_planner/core/models/focus_record.dart';
import 'package:ai_study_planner/core/system_clock.dart';
import 'package:ai_study_planner/core/timer_state_machine.dart';
import 'package:ai_study_planner/data/repositories/focus_repository.dart';

/// Notifier untuk Focus Timer.
class FocusTimerNotifier extends ChangeNotifier {
  FocusTimerNotifier(this._focusRepository, {Clock? clock})
      : _clock = clock ?? SystemClock(),
        _machine = const FocusTimerMachine(),
        _state = const TimerMachineState();

  final FocusRepository _focusRepository;
  final Clock _clock;
  final FocusTimerMachine _machine;

  TimerMachineState _state;

  TimerMachineState get state => _state;
  FocusDuration get duration => _state.duration;
  TimerState get timerState => _state.state;
  int get remainingSeconds => _state.remainingSeconds;
  int get sessionCounter => _state.sessionCounter;
  String? get relatedTaskId => _state.relatedTaskId;

  void setDuration(FocusDuration d) {
    _state = _machine.changeDuration(_state, d);
    notifyListeners();
  }

  void setRelatedTask(String? taskId) {
    _state = _machine.setTask(_state, taskId);
    notifyListeners();
  }

  void start() {
    _state = _machine.start(_state, _clock.now());
    notifyListeners();
  }

  void pause() {
    _state = _machine.pause(_state);
    notifyListeners();
  }

  void resume() {
    _state = _machine.resume(_state, _clock.now());
    notifyListeners();
  }

  void skip() {
    _state = _machine.skip(_state, _clock.now());
    notifyListeners();
  }

  void reset() {
    _state = _machine.reset(_state);
    notifyListeners();
  }

  void tick() {
    final newState = _machine.tick(_state);
    if (newState.state == TimerState.completed &&
        _state.state != TimerState.completed) {
      _saveSession();
    }
    _state = newState;
    notifyListeners();
  }

  Future<void> _saveSession() async {
    final sekarang = _clock.now();
    await _focusRepository.saveFocusRecord(
      FocusRecord(
        id: sekarang.millisecondsSinceEpoch.toString(),
        mulai: sekarang
            .subtract(Duration(minutes: _state.duration.inMinutes)),
        durasi: Duration(minutes: _state.duration.inMinutes),
        taskId: _state.relatedTaskId,
      ),
    );
  }
}
