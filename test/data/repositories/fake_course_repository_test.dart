import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_planner/core/models/course.dart';
import 'package:ai_study_planner/core/system_clock.dart';
import 'package:ai_study_planner/data/repositories/fake_course_repository.dart';

void main() {
  group('FakeCourseRepository', () {
    test('returns default courses', () async {
      final repo = FakeCourseRepository(clock: SystemClock());
      final courses = await repo.watchCourses().first;
      expect(courses.length, 4);
    });

    test('save and retrieve course', () async {
      final repo = FakeCourseRepository(clock: SystemClock());
      await repo.saveCourse(const Course(
        id: 'c-new',
        nama: 'Matematika',
        warnaIndex: 5,
        ikon: IconData(0xe804),
      ));
      final courses = await repo.watchCourses().first;
      expect(courses.any((c) => c.id == 'c-new'), isTrue);
      expect(courses.any((c) => c.nama == 'Matematika'), isTrue);
    });

    test('delete course removes it', () async {
      final repo = FakeCourseRepository(clock: SystemClock());
      await repo.deleteCourse('course-1');
      final courses = await repo.watchCourses().first;
      expect(courses.any((c) => c.id == 'course-1'), isFalse);
      expect(courses.length, 3);
    });
  });
}