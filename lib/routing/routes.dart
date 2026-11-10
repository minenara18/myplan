import 'package:ai_study_planner/core/session_policy.dart';

/// Konstanta path rute aplikasi. Hanya satu konstanta per path.
final class AppRoutes {
  AppRoutes._();

  // Shell routes (tab bawah)
  static const String beranda = '/beranda';
  static const String kalender = '/kalender';
  static const String ai = '/ai';
  static const String progres = '/progres';
  static const String profil = '/profil';

  // Non-shell routes
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String tasks = '/tugas';
  static const String tugasBaru = '/tugas/baru';
  static const String fokus = '/fokus';
  static const String ringkasMateri = '/ringkas-materi';

  /// Detail tugas selalu lewat path param, bukan state.extra.
  static String tugasDetail(String id) => '/tugas/$id';

  /// Rute /login dengan alasan (pertamaKali -> /login polos,
  /// kedaluwarsa -> /login?reason=kedaluwarsa).
  static String loginDenganAlasan(LoginReason reason) {
    switch (reason) {
      case LoginReason.kedaluwarsa:
        return '$login?$kLoginReasonParam=$kLoginReasonKedaluwarsa';
      case LoginReason.pertamaKali:
        return login;
    }
  }

  /// Benar bila query param [state] menandakan login karena kedaluwarsa.
  static bool loginKedaluwarsa(Uri uri) =>
      uri.queryParameters[kLoginReasonParam] == kLoginReasonKedaluwarsa;

  static const String root = '/';
}
