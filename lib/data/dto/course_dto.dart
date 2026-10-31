import 'package:flutter/material.dart';

import 'package:ai_study_planner/core/models/course.dart';

/// DTO mata kuliah untuk parsing keluaran API dan penulisan ke API.
class CourseDto {
  const CourseDto._();

  /// Map JSON dari API (CourseResource) menjadi [Course].
  static Course fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      nama: json['nama'] as String,
      warnaIndex: json['warna_index'] as int? ?? 0,
      ikon: _parseIcon(json['ikon']),
    );
  }

  /// Ubah [Course] menjadi map yang diminta API.
  static Map<String, dynamic> toJson(Course course) {
    return {
      'nama': course.nama,
      'warna_index': course.warnaIndex,
      'ikon': course.ikon.codePoint,
    };
  }

  /// Palet bawaan konsisten dengan seed data.
  static IconData _parseIcon(dynamic value) {
    final code = value is int ? value : int.tryParse(value.toString());
    if (code == null) {
      return const IconData(0xe800, fontFamily: 'MaterialIcons');
    }
    return IconData(code, fontFamily: 'MaterialIcons');
  }
}
