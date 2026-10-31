import 'package:ai_study_planner/routing/auth_provider.dart';
import 'package:ai_study_planner/routing/routes.dart';

/// Redirect guard sebagai fungsi murni.
/// [currentRoute] adalah lokasi saat ini dari GoRouterState.matchedLocation.
/// Membaca status onboarding dan login dari [auth].
/// Mengembalikan path tujuan jika perlu redirect, atau null jika boleh lanjut.
String? redirectGuard({
  required String currentRoute,
  required AuthStatus auth,
}) {
  final loggingIn = currentRoute == AppRoutes.login;
  final registering = currentRoute == AppRoutes.register;
  final onboarding = currentRoute == AppRoutes.onboarding;

  // Belum login -> arahkan ke /login, kecuali sudah di halaman login/register/onboarding
  if (auth.needsLogin && !loggingIn && !registering && !onboarding) {
    return AppRoutes.login;
  }

  // Sudah login tapi belum onboarding -> arahkan ke /onboarding, kecuali sudah di onboarding
  if (auth.needsOnboarding && !onboarding) {
    return AppRoutes.onboarding;
  }

  // Sudah login dan sudah onboarding, tapi mencoba buka login/register -> arahkan ke beranda
  if (auth.isLoggedIn && auth.isOnboarded && (loggingIn || registering)) {
    return AppRoutes.beranda;
  }

  return null;
}