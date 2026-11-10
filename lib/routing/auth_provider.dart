import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/features/auth/presentation/notifier/auth_notifier.dart';

/// Status autentikasi yang dibaca oleh redirect guard (fungsi murni).
final class AuthStatus {
  const AuthStatus({
    required this.isOnboarded,
    required this.isLoggedIn,
  });

  final bool isOnboarded;
  final bool isLoggedIn;

  bool get needsOnboarding => isLoggedIn && !isOnboarded;
  bool get needsLogin => !isLoggedIn;
}

/// Provider status auth: dipetakan dari AuthState yang muncul
/// setelah login/register/onboarding lewat AuthNotifier.
final authStatusProvider = Provider<AuthStatus>((ref) {
  final state = ref.watch(authNotifierProvider);
  return AuthStatus(
    isOnboarded: state.isOnboardingCompleted,
    isLoggedIn: state.isLoggedIn,
  );
});
