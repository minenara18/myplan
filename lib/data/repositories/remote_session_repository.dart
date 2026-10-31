import 'package:dio/dio.dart';

import 'package:ai_study_planner/core/models/study_session.dart';
import 'package:ai_study_planner/data/api/failure_mapper.dart';
import 'package:ai_study_planner/data/dto/study_session_dto.dart';
import 'package:ai_study_planner/data/repositories/session_repository.dart';

/// Implementasi remote dari SessionRepository melalui Dio.
/// Pembacaan memancarkan satu snapshot; polling ditambahkan belakangan.
class RemoteSessionRepository implements SessionRepository {
  RemoteSessionRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;
  static const _failureMapper = FailureMapper();

  @override
  Stream<List<StudySession>> watchSessions() async* {
    try {
      final response = await _dio.get<Object?>('/sessions');
      final data =
          (response.data as Map<String, dynamic>)['data'] as List;
      yield data
          .map((item) => StudySessionDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _failureMapper.fromDio(e);
    }
  }

  @override
  Stream<List<StudySession>> watchSessionsByCourse(String courseId) async* {
    try {
      final response = await _dio.get<Object?>(
        '/sessions',
        queryParameters: {'course_id': courseId},
      );
      final data =
          (response.data as Map<String, dynamic>)['data'] as List;
      yield data
          .map((item) => StudySessionDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _failureMapper.fromDio(e);
    }
  }

  @override
  Future<void> saveSession(StudySession session) async {
    try {
      final body = StudySessionDto.toJson(session);
      await _dio.put<Object?>('/sessions/${session.id}', data: body);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Belum ada di server — buat baru.
        try {
          await _dio.post<Object?>(
            '/sessions',
            data: StudySessionDto.toJson(session),
          );
          return;
        } on DioException catch (e2) {
          throw _failureMapper.fromDio(e2);
        }
      }
      throw _failureMapper.fromDio(e);
    }
  }

  @override
  Future<void> saveManySessions(List<StudySession> sessions) async {
    try {
      final body = {
        'sesi': sessions.map(StudySessionDto.toJson).toList(),
      };
      await _dio.post<Object?>('/sessions/bulk', data: body);
    } on DioException catch (e) {
      throw _failureMapper.fromDio(e);
    }
  }

  @override
  Future<void> deleteSession(String id) async {
    try {
      await _dio.delete<Object?>('/sessions/$id');
    } on DioException catch (e) {
      throw _failureMapper.fromDio(e);
    }
  }
}
