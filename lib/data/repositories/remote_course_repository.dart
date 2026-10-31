import 'package:dio/dio.dart';

import 'package:ai_study_planner/core/models/course.dart';
import 'package:ai_study_planner/data/api/failure_mapper.dart';
import 'package:ai_study_planner/data/dto/course_dto.dart';
import 'package:ai_study_planner/data/repositories/course_repository.dart';

/// Implementasi remote dari CourseRepository melalui Dio.
/// Pembacaan memancarkan satu snapshot; polling ditambahkan belakangan.
class RemoteCourseRepository implements CourseRepository {
  RemoteCourseRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;
  static const _failureMapper = FailureMapper();

  @override
  Stream<List<Course>> watchCourses() async* {
    yield await _fetch();
  }

  Future<List<Course>> _fetch() async {
    try {
      final response = await _dio.get('/courses');
      final data = (response.data as Map<String, dynamic>)['data'] as List;
      return data
          .map((item) => CourseDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _failureMapper.fromDio(e);
    }
  }

  @override
  Future<void> saveCourse(Course course) async {
    try {
      final body = CourseDto.toJson(course);
      await _dio.put<void>('/courses/${course.id}', data: body);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Belum ada di server — buat baru.
        try {
          await _dio.post<void>('/courses', data: CourseDto.toJson(course));
          return;
        } on DioException catch (e2) {
          throw _failureMapper.fromDio(e2);
        }
      }
      throw _failureMapper.fromDio(e);
    }
  }

  @override
  Future<void> deleteCourse(String id) async {
    try {
      await _dio.delete<void>('/courses/$id');
    } on DioException catch (e) {
      throw _failureMapper.fromDio(e);
    }
  }
}
