import 'package:ai_study_planner/core/session_policy.dart';
import 'package:ai_study_planner/routing/routes.dart';

const _kAuthRoute = [AppRoutes.onboarding, AppRoutes.login, AppRoutes.register];
const _kLoginRoute = [AppRoutes.login, AppRoutes.register];

/// Redirect guard sebagai fungsi murni.
/// [currentRoute] adalah lokasi saat ini (GoRouterState.matchedLocation,
/// tanpa query). Keputusan sesi dibaca dari [SessionKeeper].
///
/// Aturan:
/// - /splash tidak pernah di-redirect: splash yang memilih tujuan.
/// - [decision] null (splash masih berjalan) memaksa kembali ke /splash,
///   kecuali [splashSudahMenuju] — splash sedang menuju hasil keputusannya.
/// - [NeedsOnboarding] hanya mengizinkan /onboarding, /login, /register.
/// - [NeedsLogin] hanya mengizinkan /login dan /register.
/// - [Authenticated] memaksa /onboarding, /login, /register ke /beranda.
String? redirectGuard({
  required String currentRoute,
  required SessionDecision? decision,
  required bool splashSudahMenuju,
}) {
  if (currentRoute == AppRoutes.splash) return null;

  if (decision == null) {
    return splashSudahMenuju ? null : AppRoutes.splash;
  }

  switch (decision) {
    case NeedsOnboarding():
      return _kAuthRoute.contains(currentRoute) ? null : AppRoutes.onboarding;
    case NeedsLogin(:final reason):
      if (_kLoginRoute.contains(currentRoute)) return null;
      return AppRoutes.loginDenganAlasan(reason);
    case Authenticated():
      return _kAuthRoute.contains(currentRoute) ? AppRoutes.beranda : null;
  }
}
