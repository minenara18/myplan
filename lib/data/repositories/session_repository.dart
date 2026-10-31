import 'package:ai_study_planner/core/models/study_session.dart';
import 'package:ai_study_planner/features/calendar/presentation/notifier/calendar_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Interface repositori sesi studi.
/// Stream untuk pembacaan, satu jalur penulisan.
abstract class SessionRepository {
  /// Stream semua sesi studi.
  Stream<List<StudySession>> watchSessions();

  /// Stream sesi studi dari satu mata kuliah.
  Stream<List<StudySession>> watchSessionsByCourse(String courseId);

  /// Simpan atau perbarui satu sesi studi.
  Future<void> saveSession(StudySession session);

  /// Simpan banyak sesi dalam satu operasi (bulk).
  Future<void> saveManySessions(List<StudySession> sessions);

  /// Hapus sesi studi berdasarkan id.
  Future<void> deleteSession(String id);
}

/// Provider SessionRepository — melempar UnimplementedError sampai di-override di bootstrap.
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  throw UnimplementedError(
    'SessionRepository belum di-override di bootstrap. '
    'Gunakan FakeSessionRepository atau RemoteSessionRepository.',
  );
});

/// Provider CalendarNotifier.
final calendarNotifierProvider =
    ChangeNotifierProvider<CalendarNotifier>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return CalendarNotifier(repo);
});