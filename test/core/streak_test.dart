import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_planner/core/clock.dart';
import 'package:ai_study_planner/core/models/focus_record.dart';
import 'package:ai_study_planner/core/streak.dart';
import 'package:ai_study_planner/core/system_clock.dart';

/// Clock palsu untuk pengujian streak.
class FakeClock implements Clock {
  FakeClock(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;
}

void main() {
  group('calculateStreak', () {
    test('returns 0 when no records', () {
      final clock = FakeClock(DateTime(2026, 11, 5, 10, 0));
      expect(calculateStreak([], clock), 0);
    });

    test('returns 1 when only today has record', () {
      final clock = FakeClock(DateTime(2026, 11, 5, 10, 0));
      final records = [
        FocusRecord(
          id: 'r1',
          mulai: DateTime(2026, 11, 5, 9, 0),
          durasi: const Duration(minutes: 30),
        ),
      ];
      expect(calculateStreak(records, clock), 1);
    });

    test('returns 2 when today and yesterday have records', () {
      final clock = FakeClock(DateTime(2026, 11, 5, 10, 0));
      final records = [
        FocusRecord(
          id: 'r1',
          mulai: DateTime(2026, 11, 5, 9, 0),
          durasi: const Duration(minutes: 30),
        ),
        FocusRecord(
          id: 'r2',
          mulai: DateTime(2026, 11, 4, 9, 0),
          durasi: const Duration(minutes: 30),
        ),
      ];
      expect(calculateStreak(records, clock), 2);
    });

    test('breaks streak when a day is missing', () {
      final clock = FakeClock(DateTime(2026, 11, 5, 10, 0));
      final records = [
        FocusRecord(
          id: 'r1',
          mulai: DateTime(2026, 11, 5, 9, 0),
          durasi: const Duration(minutes: 30),
        ),
        FocusRecord(
          id: 'r2',
          mulai: DateTime(2026, 11, 3, 9, 0),
          durasi: const Duration(minutes: 30),
        ),
      ];
      expect(calculateStreak(records, clock), 1);
    });

    test('counts multiple records on same day as one', () {
      final clock = FakeClock(DateTime(2026, 11, 5, 10, 0));
      final records = [
        FocusRecord(
          id: 'r1',
          mulai: DateTime(2026, 11, 5, 8, 0),
          durasi: const Duration(minutes: 30),
        ),
        FocusRecord(
          id: 'r2',
          mulai: DateTime(2026, 11, 5, 10, 0),
          durasi: const Duration(minutes: 45),
        ),
        FocusRecord(
          id: 'r3',
          mulai: DateTime(2026, 11, 4, 9, 0),
          durasi: const Duration(minutes: 30),
        ),
      ];
      expect(calculateStreak(records, clock), 2);
    });

    test('uses SystemClock without error', () {
      final records = [
        FocusRecord(
          id: 'r1',
          mulai: DateTime.now(),
          durasi: const Duration(minutes: 30),
        ),
      ];
      expect(() => calculateStreak(records, SystemClock()), returnsNormally);
    });
  });
}