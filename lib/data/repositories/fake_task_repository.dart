import 'package:ai_study_planner/core/clock.dart';
import 'package:ai_study_planner/core/models/task.dart';
import 'package:ai_study_planner/data/repositories/task_repository.dart';

/// Implementasi in-memory dari TaskRepository.
class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({required this.clock, List<Task>? initialTasks})
      : _tasks = initialTasks ?? _defaultTasks(clock);

  final Clock clock;
  final List<Task> _tasks;

  static List<Task> _defaultTasks(Clock clock) {
    final now = clock.now();
    return [
      Task(
        id: 'task-1',
        courseId: 'course-1',
        judul: 'Tugas Flutter UI',
        catatan: 'Buat layar onboarding dan autentikasi',
        tenggat: now.add(const Duration(days: 3)),
        estimasiMenit: 120,
        prioritas: Priority.tinggi,
        status: TaskStatus.berjalan,
      ),
      Task(
        id: 'task-2',
        courseId: 'course-2',
        judul: 'Tugas ERD',
        catatan: 'Desain skema basis data mahasiswa',
        tenggat: now.add(const Duration(days: 5)),
        estimasiMenit: 90,
        prioritas: Priority.sedang,
        status: TaskStatus.belum,
      ),
      Task(
        id: 'task-3',
        courseId: 'course-3',
        judul: 'Tugas Subnetting',
        catatan: 'Hitung subnet untuk jaringan kampus',
        tenggat: now.add(const Duration(days: 2)),
        estimasiMenit: 60,
        prioritas: Priority.tinggi,
        status: TaskStatus.belum,
      ),
      Task(
        id: 'task-4',
        courseId: 'course-4',
        judul: 'Tugas Chatbot',
        catatan: 'Implementasi sederhana menggunakan AI',
        tenggat: now.add(const Duration(days: 7)),
        estimasiMenit: 180,
        prioritas: Priority.rendah,
        status: TaskStatus.belum,
      ),
    ];
  }

  @override
  Stream<List<Task>> watchTasks() async* {
    yield _tasks;
  }

  @override
  Stream<List<Task>> watchTasksByCourse(String courseId) async* {
    yield _tasks.where((t) => t.courseId == courseId).toList();
  }

  @override
  Future<void> saveTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
    } else {
      _tasks.add(task);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
  }
}
