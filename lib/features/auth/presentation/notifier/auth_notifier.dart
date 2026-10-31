import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/data/repositories/auth_repository.dart';

/// State notifier untuk autentikasi.
class AuthNotifier extends Notifier<AuthState> {
  AuthNotifier();

  @override
  AuthState build() => const AuthState();

  /// Login dengan email dan sandi.
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final repo = ref.read(authRepositoryProvider);
    await repo.login(email, password);
    state = const AuthState(isLoading: false);
    // Refresh state dari repository
    await _refresh();
  }

  /// Daftar dengan email dan sandi.
  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final repo = ref.read(authRepositoryProvider);
    await repo.register(email, password);
    state = const AuthState(isLoading: false);
    await _refresh();
  }

  /// Login dengan Google.
  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final repo = ref.read(authRepositoryProvider);
    await repo.loginWithGoogle();
    state = const AuthState(isLoading: false);
    await _refresh();
  }

  /// Keluar.
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AuthState();
  }

  /// Setel status onboarding selesai.
  Future<void> setOnboardingCompleted(bool completed) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.setOnboardingCompleted(completed);
    state = state.copyWith(isOnboardingCompleted: completed);
  }

  Future<void> _refresh() async {
    final repo = ref.read(authRepositoryProvider);
    await for (final s in repo.watchAuthState().take(1)) {
      state = s;
    }
  }
}

/// Provider AuthRepository — melempar UnimplementedError sampai di-override di bootstrap.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError(
    'AuthRepository belum di-override di bootstrap. '
    'Gunakan FakeAuthRepository atau RemoteAuthRepository.',
  );
});

/// Provider AuthNotifier.
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);