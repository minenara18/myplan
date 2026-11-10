import 'package:dio/dio.dart';

import 'package:ai_study_planner/core/models/task.dart';
import 'package:ai_study_planner/data/api/failure_mapper.dart';
import 'package:ai_study_planner/data/dto/task_dto.dart';
import 'package:ai_study_planner/data/repositories/task_repository.dart';

/// Implementasi remote dari TaskRepository melalui Dio.
/// Pembacaan memancarkan satu snapshot; polling ditambahkan belakangan.
class RemoteTaskRepository implements TaskRepository {
  RemoteTaskRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;
  static const _failureMapper = FailureMapper();

  @override
  Stream<List<Task>> watchTasks() async* {
    yield await _fetch();
  }

  @override
  Stream<List<Task>> watchTasksByCourse(String courseId) async* {
    try {
      final response =
          await _dio.get('/tasks', queryParameters: {'course_id': courseId});
      final data = (response.data as Map<String, dynamic>)['data'] as List;
      yield data
          .map((item) => TaskDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _failureMapper.fromDio(e);
    }
  }

  Future<List<Task>> _fetch() async {
    try {
      final response = await _dio.get('/tasks');
      final data = (response.data as Map<String, dynamic>)['data'] as List;
      return data
          .map((item) => TaskDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _failureMapper.fromDio(e);
    }
  }

  @override
  Future<void> saveTask(Task task) async {
    try {
      final body = TaskDto.toJson(task);
      await _dio.put<Object?>('/tasks/${task.id}', data: body);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Belum ada di server — buat baru.
        try {
          await _dio.post<Object?>('/tasks', data: TaskDto.toJson(task));
          return;
        } on DioException catch (e2) {
          throw _failureMapper.fromDio(e2);
        }
      }
      throw _failureMapper.fromDio(e);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _dio.delete<Object?>('/tasks/$id');
    } on DioException catch (e) {
      throw _failureMapper.fromDio(e);
    }
  }
}
