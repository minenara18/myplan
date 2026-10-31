import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_planner/core/models/task.dart';
import 'package:ai_study_planner/core/system_clock.dart';
import 'package:ai_study_planner/data/repositories/fake_task_repository.dart';
import 'package:ai_study_planner/features/tasks/presentation/notifier/tasks_notifier.dart';

void main() {
  group('TasksNotifier', () {
    late FakeTaskRepository repo;
    late TasksNotifier notifier;

    setUp(() {
      repo = FakeTaskRepository(clock: SystemClock());
      notifier = TasksNotifier(repo);
    });

    test('initial state is loading', () {
      expect(notifier.state, isA<TasksLoading>());
    });

    test('load populates tasks', () async {
      await notifier.load();
      expect(notifier.state, isA<TasksContent>());
      final content = notifier.state as TasksContent;
      expect(content.tasks.length, 4);
    });

    test('filter today shows only today tasks', () async {
      await notifier.load();
      // Tambah task dengan tenggat hari ini
      await notifier.addTask(Task(
        id: 't-today',
        courseId: 'course-1',
        judul: 'Tugas Hari Ini',
        tenggat: DateTime.now(),
        estimasiMenit: 30,
        prioritas: Priority.sedang,
        status: TaskStatus.belum,
      ));
      notifier.setFilter('today');
      expect(notifier.filter, 'today');
      final state = notifier.state;
      expect(state, isA<TasksContent>());
      final content = state as TasksContent;
      expect(content.tasks.isNotEmpty, isTrue);
      final today = DateTime.now();
      for (final t in content.tasks) {
        expect(t.tenggat.day, today.day);
      }
    });

    test('addTask increases task count', () async {
      await notifier.load();
      final initialCount = (notifier.state as TasksContent).tasks.length;
      await notifier.addTask(Task(
        id: 't-new',
        courseId: 'course-1',
        judul: 'Tugas Baru',
        tenggat: SystemClock().now().add(const Duration(days: 1)),
        estimasiMenit: 30,
        prioritas: Priority.rendah,
        status: TaskStatus.belum,
      ));
      final state = notifier.state;
      expect(state, isA<TasksContent>());
      final content = state as TasksContent;
      expect(content.tasks.length, initialCount + 1);
    });

    test('toggleComplete changes status', () async {
      await notifier.load();
      final task = (notifier.state as TasksContent).tasks.first;
      await notifier.toggleComplete(task.id);
      final state = notifier.state;
      expect(state, isA<TasksContent>());
      final content = state as TasksContent;
      final updated = content.tasks.firstWhere((t) => t.id == task.id);
      expect(updated.status, TaskStatus.selesai);
    });

    test('softDelete then undoDelete restores', () async {
      await notifier.load();
      final task = (notifier.state as TasksContent).tasks.first;
      await notifier.softDelete(task.id);
      await notifier.undoDelete(task.id);
      final state = notifier.state;
      expect(state, isA<TasksContent>());
      final content = state as TasksContent;
      final restored = content.tasks.firstWhere((t) => t.id == task.id);
      expect(restored.status, TaskStatus.belum);
    });
  });
}