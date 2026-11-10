import 'package:flutter/foundation.dart';

import 'package:ai_study_planner/core/clock.dart';
import 'package:ai_study_planner/core/models/focus_record.dart';
import 'package:ai_study_planner/core/streak.dart';
import 'package:ai_study_planner/core/system_clock.dart';
import 'package:ai_study_planner/data/repositories/focus_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State untuk HomeNotifier.
sealed class HomeState {}

final class HomeLoading extends HomeState {}

final class HomeContent extends HomeState {
  HomeContent({
    required this.focusRecords,
    required this.streak,
    required this.todayProgress,
  });

  final List<FocusRecord> focusRecords;
  final int streak;
  final double todayProgress;
}

final class HomeError extends HomeState {
  HomeError(this.message);

  final String message;
}

/// Notifier untuk layar beranda.
class HomeNotifier extends ChangeNotifier {
  HomeNotifier(this._focusRepository, {required Clock clock}) : _clock = clock;

  final FocusRepository _focusRepository;
  final Clock _clock;

  HomeState _state = HomeLoading();
  int _streak = 0;
  double _todayProgress = 0.0;

  HomeState get state => _state;
  int get streak => _streak;
  double get todayProgress => _todayProgress;

  Future<void> load() async {
    _state = HomeLoading();
    notifyListeners();
    try {
      final records = await _focusRepository.watchFocusRecords().first;
      _streak = calculateStreak(records, _clock);
      final today = _clock.now();
      final todayRecords = records.where((r) {
        return r.mulai.year == today.year &&
            r.mulai.month == today.month &&
            r.mulai.day == today.day;
      }).toList();
      final totalDuration =
          todayRecords.fold<int>(0, (sum, r) => sum + r.durasi.inMinutes);
      _todayProgress = (totalDuration / 60).clamp(0.0, 1.0);
      _state = HomeContent(
          focusRecords: records,
          streak: _streak,
          todayProgress: _todayProgress);
    } catch (e) {
      _state = HomeError(e.toString());
    }
    notifyListeners();
  }
}

/// Provider HomeNotifier; memuat data saat pertama dibaca.
final homeNotifierProvider = ChangeNotifierProvider<HomeNotifier>((ref) {
  return HomeNotifier(
    ref.watch(focusRepositoryProvider),
    clock: ref.watch(clockProvider),
  )..load();
});
