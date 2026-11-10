import 'package:ai_study_planner/core/clock.dart';
import 'package:ai_study_planner/core/models/study_session.dart';
import 'package:ai_study_planner/data/repositories/session_repository.dart';

/// Implementasi in-memory dari SessionRepository.
class FakeSessionRepository implements SessionRepository {
  FakeSessionRepository(
      {required this.clock, List<StudySession>? initialSessions})
      : _sessions = initialSessions ?? _defaultSessions(clock);

  final Clock clock;
  final List<StudySession> _sessions;

  static List<StudySession> _defaultSessions(Clock clock) {
    final now = clock.now();
    return [
      StudySession(
        id: 'session-1',
        taskId: 'task-1',
        courseId: 'course-1',
        mulai: now.subtract(const Duration(hours: 2)),
        selesai: now.subtract(const Duration(hours: 1)),
        sumber: SessionSource.manual,
      ),
      StudySession(
        id: 'session-2',
        taskId: null,
        courseId: 'course-2',
        mulai: now.subtract(const Duration(days: 1, hours: 3)),
        selesai: now.subtract(const Duration(days: 1, hours: 1)),
        sumber: SessionSource.ai,
      ),
    ];
  }

  @override
  Stream<List<StudySession>> watchSessions() async* {
    yield _sessions;
  }

  @override
  Stream<List<StudySession>> watchSessionsByCourse(String courseId) async* {
    yield _sessions.where((s) => s.courseId == courseId).toList();
  }

  @override
  Future<void> saveSession(StudySession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index >= 0) {
      _sessions[index] = session;
    } else {
      _sessions.add(session);
    }
  }

  @override
  Future<void> saveManySessions(List<StudySession> sessions) async {
    for (final session in sessions) {
      await saveSession(session);
    }
  }

  @override
  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
  }
}
