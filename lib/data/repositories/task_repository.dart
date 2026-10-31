import 'package:ai_study_planner/core/models/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Interface repositori tugas.
/// Stream untuk pembacaan, satu jalur penulisan.
abstract class TaskRepository {
  /// Stream daftar semua tugas.
  Stream<List<Task>> watchTasks();

  /// Stream tugas dari satu mata kuliah.
  Stream<List<Task>> watchTasksByCourse(String courseId);

  /// Simpan atau perbarui satu tugas.
  Future<void> saveTask(Task task);

  /// Hapus tugas berdasarkan id.
  Future<void> deleteTask(String id);
}

/// Provider TaskRepository — melempar UnimplementedError sampai di-override di bootstrap.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  throw UnimplementedError(
    'TaskRepository belum di-override di bootstrap. '
    'Gunakan FakeTaskRepository atau RemoteTaskRepository.',
  );
});
