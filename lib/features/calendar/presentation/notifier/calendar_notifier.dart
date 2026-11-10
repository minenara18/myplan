import 'package:flutter/foundation.dart';

import 'package:ai_study_planner/core/clock.dart';
import 'package:ai_study_planner/core/models/study_session.dart';
import 'package:ai_study_planner/core/system_clock.dart';
import 'package:ai_study_planner/data/repositories/session_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State untuk CalendarNotifier.
sealed class CalendarState {}

final class CalendarLoading extends CalendarState {}

final class CalendarContent extends CalendarState {
  CalendarContent(this.sessionsByDay);

  final Map<DateTime, List<StudySession>> sessionsByDay;
}

final class CalendarEmpty extends CalendarState {}

final class CalendarError extends CalendarState {
  CalendarError(this.message);

  final String message;
}

/// Notifier untuk kalender belajar.
class CalendarNotifier extends ChangeNotifier {
  CalendarNotifier(this._sessionRepository, {required Clock clock})
      : _selectedDay = _tanggal(clock.now());

  final SessionRepository _sessionRepository;

  CalendarState _state = CalendarLoading();
  DateTime _selectedDay;
  Map<DateTime, List<StudySession>> _allSessions = {};

  /// Awal hari lewat Clock yang disuntik, bukan DateTime.now().
  static DateTime _tanggal(DateTime waktu) =>
      DateTime(waktu.year, waktu.month, waktu.day);

  CalendarState get state => _state;
  DateTime get selectedDay => _selectedDay;
  List<StudySession> get sessionsForSelectedDay =>
      _allSessions[_selectedDay] ?? [];

  Future<void> load() async {
    _state = CalendarLoading();
    notifyListeners();
    try {
      _allSessions = {};
      await for (final sessions in _sessionRepository.watchSessions().take(1)) {
        for (final s in sessions) {
          final day = _tanggal(s.mulai);
          _allSessions.putIfAbsent(day, () => []).add(s);
        }
      }
      _state = _allSessions.isEmpty
          ? CalendarEmpty()
          : CalendarContent(_allSessions);
    } catch (e) {
      _state = CalendarError(e.toString());
    }
    notifyListeners();
  }

  void selectDay(DateTime day) {
    _selectedDay = _tanggal(day);
    notifyListeners();
  }

  /// Menyimpan sesi baru lalu memuat ulang data kalender.
  Future<void> tambahSesi(StudySession session) async {
    await _sessionRepository.saveSession(session);
    await load();
  }

  void previousWeek() {
    _selectedDay = _selectedDay.subtract(const Duration(days: 7));
    notifyListeners();
  }

  void nextWeek() {
    _selectedDay = _selectedDay.add(const Duration(days: 7));
    notifyListeners();
  }

  List<DateTime> get weekDays {
    final start =
        _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }
}

/// Provider CalendarNotifier; memuat sesi saat pertama dibaca.
final calendarNotifierProvider =
    ChangeNotifierProvider<CalendarNotifier>((ref) {
  return CalendarNotifier(
    ref.watch(sessionRepositoryProvider),
    clock: ref.watch(clockProvider),
  )..load();
});
