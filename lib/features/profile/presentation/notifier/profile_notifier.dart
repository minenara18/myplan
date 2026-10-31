import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/core/failure.dart';
import 'package:ai_study_planner/data/repositories/settings_repository.dart';

/// Notifier untuk Profile.
class ProfileNotifier extends ChangeNotifier {
  ProfileNotifier(this._settingsRepository);

  final SettingsRepository _settingsRepository;

  AppSettings? _settings;
  bool _isLoading = true;
  String? _errorMessage;

  AppSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _settings = await _settingsRepository.getSettings();
    } on Failure catch (failure) {
      _errorMessage = failure.message;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan saat memuat data';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveSettings(AppSettings settings) async {
    try {
      await _settingsRepository.saveSettings(settings);
      _settings = settings;
    } on Failure catch (failure) {
      _errorMessage = failure.message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    // TODO: implement logout logic
  }
}

/// Provider ProfileNotifier.
final profileNotifierProvider =
    ChangeNotifierProvider<ProfileNotifier>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return ProfileNotifier(repo);
});
