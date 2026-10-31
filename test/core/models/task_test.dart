import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_planner/core/models/task.dart';

void main() {
  group('Task', () {
    test('copyWith produces equal copy when no changes', () {
      final task = Task(
        id: 't1',
        courseId: 'c1',
        judul: 'Tugas UI',
        tenggat: DateTime(2026, 11, 5),
        estimasiMenit: 120,
        prioritas: Priority.tinggi,
        status: TaskStatus.belum,
      );
      final copy = task.copyWith();
      expect(copy, equals(task));
    });

    test('copyWith changes only specified fields', () {
      final task = Task(
        id: 't1',
        courseId: 'c1',
        judul: 'Tugas UI',
        tenggat: DateTime(2026, 11, 5),
        estimasiMenit: 120,
        prioritas: Priority.tinggi,
        status: TaskStatus.belum,
      );
      final copy = task.copyWith(
        judul: 'Tugas UX',
        status: TaskStatus.selesai,
      );
      expect(copy.judul, 'Tugas UX');
      expect(copy.status, TaskStatus.selesai);
      expect(copy.prioritas, Priority.tinggi);
    });

    test('equality works for same values', () {
      final now = DateTime(2026, 11, 5);
      final a = Task(
        id: 't1',
        courseId: 'c1',
        judul: 'X',
        tenggat: now,
        estimasiMenit: 60,
        prioritas: Priority.sedang,
        status: TaskStatus.belum,
      );
      final b = Task(
        id: 't1',
        courseId: 'c1',
        judul: 'X',
        tenggat: now,
        estimasiMenit: 60,
        prioritas: Priority.sedang,
        status: TaskStatus.belum,
      );
      expect(a, equals(b));
    });

    test('inequality works for different values', () {
      final now = DateTime(2026, 11, 5);
      final a = Task(
        id: 't1',
        courseId: 'c1',
        judul: 'X',
        tenggat: now,
        estimasiMenit: 60,
        prioritas: Priority.sedang,
        status: TaskStatus.belum,
      );
      final b = Task(
        id: 't2',
        courseId: 'c1',
        judul: 'X',
        tenggat: now,
        estimasiMenit: 60,
        prioritas: Priority.sedang,
        status: TaskStatus.belum,
      );
      expect(a, isNot(equals(b)));
    });
  });
}