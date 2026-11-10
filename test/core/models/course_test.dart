import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_planner/core/models/course.dart';

void main() {
  group('Course', () {
    test('copyWith produces equal copy when no changes', () {
      final course = Course(
        id: 'c1',
        nama: 'Pemrograman Mobile',
        warnaIndex: 0,
        ikon: const IconData(0xe800),
      );
      final copy = course.copyWith();
      expect(copy, equals(course));
    });

    test('copyWith changes only specified fields', () {
      final course = Course(
        id: 'c1',
        nama: 'Pemrograman Mobile',
        warnaIndex: 0,
        ikon: const IconData(0xe800),
      );
      final copy = course.copyWith(nama: 'Basis Data', warnaIndex: 1);
      expect(copy.id, 'c1');
      expect(copy.nama, 'Basis Data');
      expect(copy.warnaIndex, 1);
      expect(copy.ikon, const IconData(0xe800));
    });

    test('equality works for same values', () {
      const a = Course(
        id: 'c1',
        nama: 'X',
        warnaIndex: 0,
        ikon: IconData(0xe800),
      );
      const b = Course(
        id: 'c1',
        nama: 'X',
        warnaIndex: 0,
        ikon: IconData(0xe800),
      );
      expect(a, equals(b));
    });

    test('inequality works for different values', () {
      const a = Course(
        id: 'c1',
        nama: 'X',
        warnaIndex: 0,
        ikon: IconData(0xe800),
      );
      const b = Course(
        id: 'c2',
        nama: 'X',
        warnaIndex: 0,
        ikon: IconData(0xe800),
      );
      expect(a, isNot(equals(b)));
    });
  });
}
