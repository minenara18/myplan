import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_planner/routing/auth_provider.dart';
import 'package:ai_study_planner/routing/redirect_guard.dart';
import 'package:ai_study_planner/routing/routes.dart';

void main() {
  group('Redirect Guard', () {
    test('belum login dan tidak di halaman login -> redirect ke /login',
        () {
      final auth = const AuthStatus(isOnboarded: false, isLoggedIn: false);

      final result = redirectGuard(
        currentRoute: AppRoutes.beranda,
        auth: auth,
      );

      expect(result, AppRoutes.login);
    });

    test('belum login tetapi sudah di /login -> null (boleh lanjut)', () {
      final auth = const AuthStatus(isOnboarded: false, isLoggedIn: false);

      final result = redirectGuard(
        currentRoute: AppRoutes.login,
        auth: auth,
      );

      expect(result, isNull);
    });

    test('belum login tetapi sudah di /register -> null (boleh lanjut)', () {
      final auth = const AuthStatus(isOnboarded: false, isLoggedIn: false);

      final result = redirectGuard(
        currentRoute: AppRoutes.register,
        auth: auth,
      );

      expect(result, isNull);
    });

    test('belum login tetapi sudah di /onboarding -> null (boleh lanjut)', () {
      final auth = const AuthStatus(isOnboarded: false, isLoggedIn: false);

      final result = redirectGuard(
        currentRoute: AppRoutes.onboarding,
        auth: auth,
      );

      expect(result, isNull);
    });

    test('sudah login tapi belum onboarding dan tidak di /onboarding -> redirect ke /onboarding',
        () {
      final auth = const AuthStatus(isOnboarded: false, isLoggedIn: true);

      final result = redirectGuard(
        currentRoute: AppRoutes.beranda,
        auth: auth,
      );

      expect(result, AppRoutes.onboarding);
    });

    test('sudah login dan sudah onboarding, buka /login -> redirect ke /beranda',
        () {
      final auth = const AuthStatus(isOnboarded: true, isLoggedIn: true);

      final result = redirectGuard(
        currentRoute: AppRoutes.login,
        auth: auth,
      );

      expect(result, AppRoutes.beranda);
    });

    test('sudah login dan sudah onboarding, buka /register -> redirect ke /beranda',
        () {
      final auth = const AuthStatus(isOnboarded: true, isLoggedIn: true);

      final result = redirectGuard(
        currentRoute: AppRoutes.register,
        auth: auth,
      );

      expect(result, AppRoutes.beranda);
    });

    test('sudah login dan sudah onboarding, buka /beranda -> null (boleh lanjut)',
        () {
      final auth = const AuthStatus(isOnboarded: true, isLoggedIn: true);

      final result = redirectGuard(
        currentRoute: AppRoutes.beranda,
        auth: auth,
      );

      expect(result, isNull);
    });
  });
}