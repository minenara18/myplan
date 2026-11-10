import 'package:flutter/foundation.dart';

import 'package:ai_study_planner/core/clock.dart';
import 'package:ai_study_planner/core/models/task.dart';
import 'package:ai_study_planner/core/system_clock.dart';
import 'package:ai_study_planner/data/repositories/task_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State sealed untuk TasksNotifier.
sealed class TasksState {}

/// Masih memuat data.
final class TasksLoading extends TasksState {}

/// Data berhasil dimuat.
final class TasksContent extends TasksState {
  TasksContent(this.tasks);

  final List<Task> tasks;
}

/// Tidak ada tugas.
final class TasksEmpty extends TasksState {}

/// Terjadi kesalahan saat memuat.
final class TasksError extends TasksState {
  TasksError(this.message);

  final String message;
}

/// Notifier untuk manajemen daftar tugas.
class TasksNotifier extends ChangeNotifier {
  TasksNotifier(this._taskRepository, {required Clock clock}) : _clock = clock;

  final TaskRepository _taskRepository;
  final Clock _clock;

  TasksState _state = TasksLoading();
  List<Task> _allTasks = [];
  String _filter = 'all'; // all, today, week, completed
  String? _subjectFilter;

  TasksState get state => _state;
  List<Task> get tasks => _filteredTasks();
  String get filter => _filter;
  String? get subjectFilter => _subjectFilter;

  Future<void> load() async {
    _state = TasksLoading();
    notifyListeners();
    try {
      _allTasks = await _taskRepository.watchTasks().first;
      _state = _allTasks.isEmpty ? TasksEmpty() : TasksContent(_allTasks);
    } catch (e) {
      _state = TasksError(e.toString());
    }
    notifyListeners();
  }

  void setFilter(String filter) {
    _filter = filter;
    _subjectFilter = null;
    _applyState();
  }

  void setSubjectFilter(String subject) {
    _subjectFilter = subject;
    _filter = 'all';
    _applyState();
  }

  void _applyState() {
    final filtered = _filteredTasks();
    if (filtered.isEmpty) {
      _state = TasksEmpty();
    } else {
      _state = TasksContent(filtered);
    }
    notifyListeners();
  }

  List<Task> _filteredTasks() {
    final now = _clock.now();
    return _allTasks.where((task) {
      if (_filter == 'today') {
        final t = task.tenggat;
        if (t.year != now.year || t.month != now.month || t.day != now.day) {
          return false;
        }
      } else if (_filter == 'week') {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        final t = task.tenggat;
        if (t.isBefore(startOfWeek) || t.isAfter(endOfWeek)) {
          return false;
        }
      } else if (_filter == 'completed') {
        if (task.status != TaskStatus.selesai) return false;
      }
      if (_subjectFilter != null && task.courseId != _subjectFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> addTask(Task task) async {
    await _taskRepository.saveTask(task);
    await load();
  }

  Future<void> updateTask(Task task) async {
    await _taskRepository.saveTask(task);
    await load();
  }

  Future<void> softDelete(String id) async {
    final task = _allTasks.firstWhere((t) => t.id == id);
    await _taskRepository.saveTask(task.copyWith(status: TaskStatus.selesai));
    await load();
  }

  Future<void> undoDelete(String id) async {
    final task = _allTasks.firstWhere((t) => t.id == id);
    await _taskRepository.saveTask(task.copyWith(status: TaskStatus.belum));
    await load();
  }

  Future<void> toggleComplete(String id) async {
    final task = _allTasks.firstWhere((t) => t.id == id);
    final newStatus = task.status == TaskStatus.selesai
        ? TaskStatus.belum
        : TaskStatus.selesai;
    await _taskRepository.saveTask(task.copyWith(status: newStatus));
    await load();
  }

  Future<void> deleteTask(String id) async {
    await _taskRepository.deleteTask(id);
    await load();
  }

  List<Task> get completedTasks =>
      _allTasks.where((t) => t.status == TaskStatus.selesai).toList();
  List<Task> get pendingTasks =>
      _allTasks.where((t) => t.status != TaskStatus.selesai).toList();
}

/// Provider TasksNotifier; memuat data saat pertama dibaca sehingga
/// layar tidak pernah berdiam di state Loading.
final tasksNotifierProvider = ChangeNotifierProvider<TasksNotifier>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return TasksNotifier(
    repo,
    clock: ref.watch(clockProvider),
  )..load();
});
