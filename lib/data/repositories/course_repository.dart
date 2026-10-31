import 'package:ai_study_planner/core/models/course.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Interface repositori mata kuliah.
/// Stream untuk pembacaan, satu jalur penulisan.
abstract class CourseRepository {
  /// Stream daftar semua mata kuliah.
  Stream<List<Course>> watchCourses();

  /// Simpan atau perbarui satu mata kuliah.
  Future<void> saveCourse(Course course);

  /// Hapus mata kuliah berdasarkan id.
  Future<void> deleteCourse(String id);
}

/// Provider CourseRepository — melempar UnimplementedError sampai di-override di bootstrap.
final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  throw UnimplementedError(
    'CourseRepository belum di-override di bootstrap. '
    'Gunakan FakeCourseRepository atau RemoteCourseRepository.',
  );
});