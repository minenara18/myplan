import 'package:shared_preferences/shared_preferences.dart';

/// Kunci penyimpanan penanda onboarding selesai.
const String kOnboardingCompletedKey = 'onboarding_completed';

/// Service untuk menyimpan dan membaca penanda onboarding selesai.
/// Dirancang untuk dapat diganti (mock) saat pengujian.
abstract class OnboardingPreferencesService {
  /// Apakah onboarding telah selesai?
  Future<bool> isOnboardingCompleted();

  /// Tandai onboarding sebagai selesai.
  Future<void> setOnboardingCompleted(bool completed);
}

/// Implementasi nyata menggunakan shared_preferences.
class SharedPreferencesOnboardingService
    implements OnboardingPreferencesService {
  SharedPreferencesOnboardingService(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<bool> isOnboardingCompleted() async {
    return _prefs.getBool(kOnboardingCompletedKey) ?? false;
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(kOnboardingCompletedKey, completed);
  }
}

/// Implementasi palsu untuk pengujian.
class FakeOnboardingPreferencesService implements OnboardingPreferencesService {
  FakeOnboardingPreferencesService({this.completed = false});

  bool completed;

  @override
  Future<bool> isOnboardingCompleted() async => completed;

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    this.completed = completed;
  }
}
