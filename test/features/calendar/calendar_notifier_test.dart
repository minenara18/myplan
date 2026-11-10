import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_planner/core/system_clock.dart';
import 'package:ai_study_planner/data/repositories/fake_session_repository.dart';
import 'package:ai_study_planner/features/calendar/presentation/notifier/calendar_notifier.dart';

void main() {
  group('CalendarNotifier', () {
    late FakeSessionRepository repo;
    late CalendarNotifier notifier;

    setUp(() {
      repo = FakeSessionRepository(clock: SystemClock());
      notifier = CalendarNotifier(repo, clock: SystemClock());
    });

    test('initial state is loading', () {
      expect(notifier.state, isA<CalendarLoading>());
    });

    test('load populates sessions', () async {
      await notifier.load();
      expect(notifier.state, isA<CalendarContent>());
      final content = notifier.state as CalendarContent;
      expect(content.sessionsByDay.length, greaterThan(0));
    });

    test('selectDay changes selected day', () {
      final newDay = DateTime(2026, 11, 10);
      notifier.selectDay(newDay);
      expect(notifier.selectedDay, DateTime(2026, 11, 10));
    });

    test('previousWeek and nextWeek change selected day', () {
      final initial = notifier.selectedDay;
      notifier.nextWeek();
      expect(notifier.selectedDay, initial.add(const Duration(days: 7)));
      notifier.previousWeek();
      expect(notifier.selectedDay, initial);
    });

    test('weekDays returns 7 days', () {
      expect(notifier.weekDays.length, 7);
    });

    test('sessionsForSelectedDay filters by day', () async {
      await notifier.load();
      final selected = notifier.selectedDay;
      final sessions = notifier.sessionsForSelectedDay;
      for (final s in sessions) {
        expect(s.mulai.year, selected.year);
        expect(s.mulai.month, selected.month);
        expect(s.mulai.day, selected.day);
      }
    });
  });
}
