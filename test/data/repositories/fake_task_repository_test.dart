import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_planner/core/models/task.dart';
import 'package:ai_study_planner/core/system_clock.dart';
import 'package:ai_study_planner/data/repositories/fake_task_repository.dart';

void main() {
  group('FakeTaskRepository', () {
    test('returns default tasks', () async {
      final repo = FakeTaskRepository(clock: SystemClock());
      final tasks = await repo.watchTasks().first;
      expect(tasks.length, 4);
    });

    test('watchTasksByCourse filters correctly', () async {
      final repo = FakeTaskRepository(clock: SystemClock());
      final tasks = await repo.watchTasksByCourse('course-1').first;
      expect(tasks.every((t) => t.courseId == 'course-1'), isTrue);
    });

    test('save and retrieve task', () async {
      final repo = FakeTaskRepository(clock: SystemClock());
      await repo.saveTask(Task(
        id: 't-new',
        courseId: 'course-1',
        judul: 'Tugas Baru',
        tenggat: SystemClock().now().add(const Duration(days: 1)),
        estimasiMenit: 30,
        prioritas: Priority.rendah,
        status: TaskStatus.belum,
      ));
      final tasks = await repo.watchTasks().first;
      expect(tasks.any((t) => t.id == 't-new'), isTrue);
    });

    test('delete task removes it', () async {
      final repo = FakeTaskRepository(clock: SystemClock());
      await repo.deleteTask('task-1');
      final tasks = await repo.watchTasks().first;
      expect(tasks.any((t) => t.id == 'task-1'), isFalse);
      expect(tasks.length, 3);
    });
  });
}