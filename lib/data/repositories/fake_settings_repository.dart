import 'package:ai_study_planner/data/repositories/settings_repository.dart';

/// Implementasi palsu dari SettingsRepository.
class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({AppSettings? initialSettings})
      : _settings = initialSettings ??
          const AppSettings(
            reminderEnabled: true,
            defaultPomodoroMinutes: 25,
            dailyFreeTimeStart: 16,
            dailyFreeTimeEnd: 21,
          );

  AppSettings _settings;

  @override
  Future<AppSettings> getSettings() async => _settings;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
  }
}