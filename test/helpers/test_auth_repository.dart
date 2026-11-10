import 'package:ai_study_planner/data/repositories/auth_repository.dart';
import 'package:ai_study_planner/services/onboarding_preferences_service.dart';

/// Fake AuthRepository deterministik untuk integration test.
/// Onboarding dibaca dari OnboardingPreferencesService (SharedPreferences
/// mock). login/register langsung sukses dan membalik status internal
/// seperti FakeAuthRepository di production code, tetapi tanpa jeda.
class FakeAuthRepositoryForTest implements AuthRepository {
  FakeAuthRepositoryForTest({
    required SharedPreferencesOnboardingService onboardingService,
  })  : _onboardingService = onboardingService;

  final SharedPreferencesOnboardingService _onboardingService;

  bool _isLoggedIn = false;

  @override
  Future<bool> isOnboardingCompleted() =>
      _onboardingService.isOnboardingCompleted();

  @override
  Future<void> setOnboardingCompleted(bool completed) =>
      _onboardingService.setOnboardingCompleted(completed);

  @override
  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw StateError('Email dan sandi tidak boleh kosong.');
    }
    _isLoggedIn = true;
  }

  @override
  Future<void> register(String email, String password) async {
    _isLoggedIn = true;
  }

  @override
  Future<void> loginWithGoogle() async {}

  @override
  Future<void> logout() async {
    _isLoggedIn = false;
  }

  @override
  Stream<AuthState> watchAuthState() async* {
    yield AuthState(
      isLoggedIn: _isLoggedIn,
      isOnboardingCompleted: await isOnboardingCompleted(),
    );
  }
}
