import 'package:flutter/material.dart';

import 'package:ai_study_planner/core/clock.dart';
import 'package:ai_study_planner/core/models/course.dart';
import 'package:ai_study_planner/data/repositories/course_repository.dart';

/// Implementasi in-memory dari CourseRepository.
class FakeCourseRepository implements CourseRepository {
  FakeCourseRepository({required this.clock, List<Course>? initialCourses})
      : _courses = initialCourses ?? _defaultCourses();

  final Clock clock;
  final List<Course> _courses;

  static List<Course> _defaultCourses() => [
        Course(
          id: 'course-1',
          nama: 'Pemrograman Mobile',
          warnaIndex: 0,
          ikon: const IconData(0xe800, fontFamily: 'MaterialIcons'),
        ),
        Course(
          id: 'course-2',
          nama: 'Basis Data',
          warnaIndex: 1,
          ikon: const IconData(0xe801, fontFamily: 'MaterialIcons'),
        ),
        Course(
          id: 'course-3',
          nama: 'Jaringan Komputer',
          warnaIndex: 2,
          ikon: const IconData(0xe802, fontFamily: 'MaterialIcons'),
        ),
        Course(
          id: 'course-4',
          nama: 'Kecerdasan Buatan',
          warnaIndex: 3,
          ikon: const IconData(0xe803, fontFamily: 'MaterialIcons'),
        ),
      ];

  @override
  Stream<List<Course>> watchCourses() async* {
    yield _courses;
  }

  @override
  Future<void> saveCourse(Course course) async {
    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index >= 0) {
      _courses[index] = course;
    } else {
      _courses.add(course);
    }
  }

  @override
  Future<void> deleteCourse(String id) async {
    _courses.removeWhere((c) => c.id == id);
  }
}
