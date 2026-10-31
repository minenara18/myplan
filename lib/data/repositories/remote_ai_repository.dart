import 'package:dio/dio.dart';

import 'package:ai_study_planner/core/failure.dart';
import 'package:ai_study_planner/core/models/ai_plan_input.dart';
import 'package:ai_study_planner/core/models/ai_plan_result.dart';
import 'package:ai_study_planner/core/models/ai_summary.dart';
import 'package:ai_study_planner/data/api/failure_mapper.dart';
import 'package:ai_study_planner/data/dto/ai_dto.dart';
import 'package:ai_study_planner/data/repositories/ai_repository.dart';

/// Implementasi remote dari AiRepository melalui Dio.
/// Timeout receive memberi kesempatan LLM selesai; kegagalan jadi Failure.
class RemoteAiRepository implements AiRepository {
  RemoteAiRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;
  static const _failureMapper = FailureMapper();

  @override
  Future<AiPlanResult> buatRencana(AiPlanInput input) async {
    try {
      final response = await _dio.post<Object?>(
        '/ai/plan',
        data: AiDto.planToJson(input),
      );

      return AiDto.planFromJson(_data(response));
    } on DioException catch (e) {
      throw _failureMapper.fromDio(e);
    }
  }

  @override
  Future<AiSummary> ringkasMateri(String teks) async {
    try {
      final response = await _dio.post<Object?>(
        '/ai/summarize',
        data: AiDto.summaryToJson(teks),
      );

      return AiDto.summaryFromJson(_data(response));
    } on DioException catch (e) {
      throw _failureMapper.fromDio(e);
    }
  }

  Map<String, dynamic> _data(Response<Object?> response) {
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw const UnknownFailure('Respons API tidak dikenali.');
    }

    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const UnknownFailure('Respons API tidak punya bagian data.');
    }

    return data;
  }
}
