import 'package:flutter/foundation.dart';

import 'package:ai_study_planner/core/models/study_session.dart';
import 'package:ai_study_planner/data/repositories/session_repository.dart';

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
  CalendarNotifier(this._sessionRepository);

  final SessionRepository _sessionRepository;

  CalendarState _state = CalendarLoading();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<StudySession>> _allSessions = {};

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
          final day = DateTime(s.mulai.year, s.mulai.month, s.mulai.day);
          _allSessions.putIfAbsent(day, () => []).add(s);
        }
      }
      _state = _allSessions.isEmpty ? CalendarEmpty() : CalendarContent(_allSessions);
    } catch (e) {
      _state = CalendarError(e.toString());
    }
    notifyListeners();
  }

  void selectDay(DateTime day) {
    _selectedDay = DateTime(day.year, day.month, day.day);
    notifyListeners();
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
    final start = _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }
}