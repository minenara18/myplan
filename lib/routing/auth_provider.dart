import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Status autentikasi dan onboarding (sementara fake).
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

/// Provider palsu (temporary fake) untuk status onboarding dan login.
/// Digunakan oleh redirect guard sebelum backend tersedia.
final class FakeAuthProvider {
  const FakeAuthProvider();

  AuthStatus get status => const AuthStatus(
        isOnboarded: false,
        isLoggedIn: false,
      );
}

/// Riverpod provider untuk FakeAuthProvider (temporary).
final fakeAuthProvider = Provider<FakeAuthProvider>((ref) => const FakeAuthProvider());

/// Riverpod provider untuk status auth yang dibaca oleh redirect guard.
final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(fakeAuthProvider).status;
});