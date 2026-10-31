import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_planner/core/models/study_session.dart';

void main() {
  group('StudySession', () {
    test('copyWith produces equal copy when no changes', () {
      final session = StudySession(
        id: 's1',
        taskId: 't1',
        courseId: 'c1',
        mulai: DateTime(2026, 11, 1, 8, 0),
        selesai: DateTime(2026, 11, 1, 9, 0),
        sumber: SessionSource.manual,
      );
      final copy = session.copyWith();
      expect(copy, equals(session));
    });

    test('copyWith changes only specified fields', () {
      final session = StudySession(
        id: 's1',
        taskId: 't1',
        courseId: 'c1',
        mulai: DateTime(2026, 11, 1, 8, 0),
        selesai: DateTime(2026, 11, 1, 9, 0),
        sumber: SessionSource.manual,
      );
      final copy = session.copyWith(
        courseId: 'c2',
        sumber: SessionSource.ai,
      );
      expect(copy.courseId, 'c2');
      expect(copy.sumber, SessionSource.ai);
      expect(copy.taskId, 't1');
    });

    test('equality works for same values', () {
      final a = StudySession(
        id: 's1',
        taskId: 't1',
        courseId: 'c1',
        mulai: DateTime(2026, 11, 1, 8, 0),
        selesai: DateTime(2026, 11, 1, 9, 0),
        sumber: SessionSource.manual,
      );
      final b = StudySession(
        id: 's1',
        taskId: 't1',
        courseId: 'c1',
        mulai: DateTime(2026, 11, 1, 8, 0),
        selesai: DateTime(2026, 11, 1, 9, 0),
        sumber: SessionSource.manual,
      );
      expect(a, equals(b));
    });

    test('taskId optional can be null', () {
      final session = StudySession(
        id: 's1',
        taskId: null,
        courseId: 'c1',
        mulai: DateTime(2026, 11, 1, 8, 0),
        selesai: DateTime(2026, 11, 1, 9, 0),
        sumber: SessionSource.ai,
      );
      expect(session.taskId, isNull);
    });
  });
}