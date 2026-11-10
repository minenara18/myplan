import 'package:dio/dio.dart';

import 'package:ai_study_planner/data/api/failure_mapper.dart';
import 'package:ai_study_planner/data/repositories/settings_repository.dart';

/// Implementasi remote dari SettingsRepository melalui Dio
/// (endpoint GET/PUT /settings pada backend).
class RemoteSettingsRepository implements SettingsRepository {
  RemoteSettingsRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;
  static const _failureMapper = FailureMapper();

  @override
  Future<AppSettings> getSettings() async {
    try {
      final response = await _dio.get<Object?>('/settings');
      final data = (response.data as Map<String, dynamic>)['data']
          as Map<String, dynamic>;
      return AppSettings(
        reminderEnabled: data['reminder_enabled'] as bool? ?? true,
        defaultPomodoroMinutes: data['default_pomodoro_minutes'] as int? ?? 25,
        dailyFreeTimeStart: data['daily_free_time_start'] as int? ?? 16,
        dailyFreeTimeEnd: data['daily_free_time_end'] as int? ?? 21,
      );
    } on DioException catch (e) {
      throw _failureMapper.fromDio(e);
    }
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    try {
      await _dio.put<Object?>(
        '/settings',
        data: {
          'reminder_enabled': settings.reminderEnabled,
          'default_pomodoro_minutes': settings.defaultPomodoroMinutes,
          'daily_free_time_start': settings.dailyFreeTimeStart,
          'daily_free_time_end': settings.dailyFreeTimeEnd,
        },
      );
    } on DioException catch (e) {
      throw _failureMapper.fromDio(e);
    }
  }
}
