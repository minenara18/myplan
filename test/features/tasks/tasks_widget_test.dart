import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_planner/core/models/task.dart';
import 'package:ai_study_planner/features/tasks/presentation/widgets/task_item_widget.dart';

void main() {
  group('TaskItemWidget', () {
    testWidgets('displays task title and priority', (WidgetTester tester) async {
      final task = Task(
        id: 't1',
        courseId: 'course-1',
        judul: 'Tugas Flutter UI',
        tenggat: DateTime(2026, 11, 10),
        estimasiMenit: 120,
        prioritas: Priority.tinggi,
        status: TaskStatus.belum,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskItemWidget(
              task: task,
              onToggle: () {},
              onDelete: () {},
              onUndo: () {},
            ),
          ),
        ),
      );

      expect(find.text('Tugas Flutter UI'), findsOneWidget);
      expect(find.text('Tinggi'), findsOneWidget);
    });

    testWidgets('checkbox toggles when tapped', (WidgetTester tester) async {
      final task = Task(
        id: 't1',
        courseId: 'course-1',
        judul: 'Tugas UI',
        tenggat: DateTime(2026, 11, 10),
        estimasiMenit: 120,
        prioritas: Priority.sedang,
        status: TaskStatus.belum,
      );

      var toggled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskItemWidget(
              task: task,
              onToggle: () => toggled = true,
              onDelete: () {},
              onUndo: () {},
            ),
          ),
        ),
      );

      // Cari GestureDetector checkbox berdasarkan key
      await tester.tap(find.byKey(const Key('task_checkbox')));
      await tester.pump();
      expect(toggled, isTrue);
    });
  });
}