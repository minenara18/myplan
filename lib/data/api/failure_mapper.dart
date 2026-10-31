import 'package:dio/dio.dart';

import 'package:ai_study_planner/core/failure.dart';

/// Pemeta DioException menjadi Failure sesuai format seragam API
/// ({message, errors, code}).
class FailureMapper {
  const FailureMapper();

  Failure fromDio(DioException error) {
    final type = error.type;
    if (type == DioExceptionType.connectionError ||
        type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout) {
      return const NetworkFailure();
    }

    final response = error.response;
    final statusCode = response?.statusCode;
    final body = response?.data;

    if (body is Map<String, dynamic>) {
      final message = (body['message'] as String?) ?? 'Terjadi kesalahan.';
      final code = body['code'] as String?;
      final errorsRaw = body['errors'];

      final errors = <String, List<String>>{};
      if (errorsRaw is Map) {
        errorsRaw.forEach((key, value) {
          if (value is List) {
            errors[key.toString()] = value.map((e) => e.toString()).toList();
          } else {
            errors[key.toString()] = [value.toString()];
          }
        });
      }

      switch (statusCode) {
        case 401:
          return UnauthorizedFailure(message, code);
        case 403:
          return ForbiddenFailure(message, code);
        case 404:
          return NotFoundFailure(message, code);
        case 422:
          return ValidationFailure(message, code, errors);
        default:
          if (statusCode != null && statusCode >= 500) {
            return ServerFailure(message, code);
          }
          return UnknownFailure(message);
      }
    }

    if (statusCode != null) {
      if (statusCode >= 500) return const ServerFailure();
    }

    return const UnknownFailure();
  }

  /// Map kegagalan apa pun menjadi Failure.
  Failure fromAny(Object error) {
    if (error is DioException) return fromDio(error);
    if (error is Failure) return error;
    return const UnknownFailure();
  }
}
