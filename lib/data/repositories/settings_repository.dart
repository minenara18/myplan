import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pengaturan aplikasi.
class AppSettings {
  const AppSettings({
    required this.reminderEnabled,
    required this.defaultPomodoroMinutes,
    required this.dailyFreeTimeStart,
    required this.dailyFreeTimeEnd,
  });

  final bool reminderEnabled;
  final int defaultPomodoroMinutes;
  final int dailyFreeTimeStart;
  final int dailyFreeTimeEnd;

  AppSettings copyWith({
    bool? reminderEnabled,
    int? defaultPomodoroMinutes,
    int? dailyFreeTimeStart,
    int? dailyFreeTimeEnd,
  }) {
    return AppSettings(
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      defaultPomodoroMinutes: defaultPomodoroMinutes ?? this.defaultPomodoroMinutes,
      dailyFreeTimeStart: dailyFreeTimeStart ?? this.dailyFreeTimeStart,
      dailyFreeTimeEnd: dailyFreeTimeEnd ?? this.dailyFreeTimeEnd,
    );
  }
}

/// Interface repositori pengaturan.
abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
}

/// Provider SettingsRepository — melempar UnimplementedError sampai di-override di bootstrap.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError(
    'SettingsRepository belum di-override di bootstrap. '
    'Gunakan FakeSettingsRepository atau RemoteSettingsRepository.',
  );
});