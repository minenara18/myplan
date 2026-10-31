import 'package:dio/dio.dart';

import 'package:ai_study_planner/core/models/focus_record.dart';
import 'package:ai_study_planner/data/api/failure_mapper.dart';
import 'package:ai_study_planner/data/dto/focus_record_dto.dart';
import 'package:ai_study_planner/data/repositories/focus_repository.dart';

/// Implementasi remote dari FocusRepository melalui Dio.
/// Pembacaan memancarkan satu snapshot; polling ditambahkan belakangan.
class RemoteFocusRepository implements FocusRepository {
  RemoteFocusRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;
  static const _failureMapper = FailureMapper();

  @override
  Stream<List<FocusRecord>> watchFocusRecords() async* {
    try {
      final response = await _dio.get<Object?>('/focus-records');
      final data = (response.data as Map<String, dynamic>)['data'] as List;
      yield data
          .map((item) => FocusRecordDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _failureMapper.fromDio(e);
    }
  }

  @override
  Future<void> saveFocusRecord(FocusRecord record) async {
    try {
      await _dio.post<Object?>(
        '/focus-records',
        data: FocusRecordDto.toJsonNew(record),
      );
    } on DioException catch (e) {
      throw _failureMapper.fromDio(e);
    }
  }

  @override
  Future<void> deleteFocusRecord(String id) async {
    try {
      await _dio.delete<Object?>('/focus-records/$id');
    } on DioException catch (e) {
      throw _failureMapper.fromDio(e);
    }
  }
}
