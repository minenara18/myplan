import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_planner/core/models/study_session.dart';
import 'package:ai_study_planner/core/system_clock.dart';
import 'package:ai_study_planner/data/repositories/fake_session_repository.dart';

void main() {
  group('FakeSessionRepository', () {
    test('returns default sessions', () async {
      final repo = FakeSessionRepository(clock: SystemClock());
      final sessions = await repo.watchSessions().first;
      expect(sessions.length, 2);
    });

    test('watchSessionsByCourse filters correctly', () async {
      final repo = FakeSessionRepository(clock: SystemClock());
      final sessions = await repo.watchSessionsByCourse('course-1').first;
      expect(sessions.every((s) => s.courseId == 'course-1'), isTrue);
    });

    test('save and retrieve session', () async {
      final repo = FakeSessionRepository(clock: SystemClock());
      await repo.saveSession(StudySession(
        id: 's-new',
        taskId: null,
        courseId: 'course-3',
        mulai: SystemClock().now(),
        selesai: SystemClock().now().add(const Duration(hours: 1)),
        sumber: SessionSource.ai,
      ));
      final sessions = await repo.watchSessions().first;
      expect(sessions.any((s) => s.id == 's-new'), isTrue);
    });

    test('delete session removes it', () async {
      final repo = FakeSessionRepository(clock: SystemClock());
      await repo.deleteSession('session-1');
      final sessions = await repo.watchSessions().first;
      expect(sessions.any((s) => s.id == 'session-1'), isFalse);
      expect(sessions.length, 1);
    });
  });
}