import 'package:ai_study_planner/core/clock.dart';
import 'package:ai_study_planner/services/onboarding_preferences_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Status autentikasi.
final class AuthState {
  const AuthState({
    this.isLoggedIn = false,
    this.isOnboardingCompleted = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isLoggedIn;
  final bool isOnboardingCompleted;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isOnboardingCompleted,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Interface repositori autentikasi.
abstract class AuthRepository {
  /// Status onboarding selesai.
  Future<bool> isOnboardingCompleted();

  /// Tandai onboarding selesai.
  Future<void> setOnboardingCompleted(bool completed);

  /// Login dengan email dan sandi.
  Future<void> login(String email, String password);

  /// Daftar dengan email dan sandi.
  Future<void> register(String email, String password);

  /// Login dengan Google (belum diimplementasi).
  Future<void> loginWithGoogle();

  /// Keluar.
  Future<void> logout();

  /// Stream status autentikasi.
  Stream<AuthState> watchAuthState();
}

/// Implementasi palsu dari AuthRepository.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    required this.clock,
    required this.onboardingService,
  });

  final Clock clock;
  final OnboardingPreferencesService onboardingService;

  bool _isLoggedIn = false;
  String? _errorMessage;

  @override
  Future<bool> isOnboardingCompleted() async {
    return await onboardingService.isOnboardingCompleted();
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    await onboardingService.setOnboardingCompleted(completed);
  }

  @override
  Future<void> login(String email, String password) async {
    _errorMessage = null;
    await Future.delayed(const Duration(seconds: 1));
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Email dan sandi tidak boleh kosong.';
      return;
    }
    _isLoggedIn = true;
  }

  @override
  Future<void> register(String email, String password) async {
    _errorMessage = null;
    await Future.delayed(const Duration(seconds: 1));
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Email dan sandi tidak boleh kosong.';
      return;
    }
    if (password.length < 6) {
      _errorMessage = 'Sandi minimal 6 karakter.';
      return;
    }
    _isLoggedIn = true;
  }

  @override
  Future<void> loginWithGoogle() async {
    _errorMessage = null;
    await Future.delayed(const Duration(seconds: 2));
    // Belum diimplementasi
    _errorMessage = 'Login dengan Google belum tersedia.';
  }

  @override
  Future<void> logout() async {
    _isLoggedIn = false;
  }

  @override
  Stream<AuthState> watchAuthState() async* {
    yield AuthState(
      isLoggedIn: _isLoggedIn,
      isOnboardingCompleted: await isOnboardingCompleted(),
      isLoading: false,
      errorMessage: _errorMessage,
    );
  }
}

/// Provider AuthRepository — melempar UnimplementedError sampai di-override di bootstrap.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError(
    'AuthRepository belum di-override di bootstrap. '
    'Gunakan FakeAuthRepository atau RemoteAuthRepository.',
  );
});
