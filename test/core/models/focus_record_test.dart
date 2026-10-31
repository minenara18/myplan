import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_planner/core/models/focus_record.dart';

void main() {
  group('FocusRecord', () {
    test('copyWith produces equal copy when no changes', () {
      final record = FocusRecord(
        id: 'f1',
        mulai: DateTime(2026, 11, 1, 8, 0),
        durasi: const Duration(minutes: 45),
        taskId: 't1',
      );
      final copy = record.copyWith();
      expect(copy, equals(record));
    });

    test('copyWith changes only specified fields', () {
      final record = FocusRecord(
        id: 'f1',
        mulai: DateTime(2026, 11, 1, 8, 0),
        durasi: const Duration(minutes: 45),
        taskId: 't1',
      );
      final copy = record.copyWith(durasi: const Duration(minutes: 30));
      expect(copy.durasi, const Duration(minutes: 30));
      expect(record.durasi, const Duration(minutes: 45));
    });

    test('equality works for same values', () {
      final a = FocusRecord(
        id: 'f1',
        mulai: DateTime(2026, 11, 1, 8, 0),
        durasi: const Duration(minutes: 45),
        taskId: 't1',
      );
      final b = FocusRecord(
        id: 'f1',
        mulai: DateTime(2026, 11, 1, 8, 0),
        durasi: const Duration(minutes: 45),
        taskId: 't1',
      );
      expect(a, equals(b));
    });
  });
}