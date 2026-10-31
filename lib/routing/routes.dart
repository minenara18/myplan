/// Konstanta path rute aplikasi.
final class AppRoutes {
  AppRoutes._();

  // Shell routes
  static const String beranda = '/beranda';
  static const String kalender = '/kalender';
  static const String ai = '/ai';
  static const String progres = '/progres';
  static const String profil = '/profil';

  // Non-shell routes
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String fokus = '/fokus';
  static const String tugasBaru = '/tugas/baru';
  static const String ringkasMateri = '/ringkas-materi';

  static String tugasDetail(String id) => '/tugas/$id';

  static const String root = '/';

  // Feature routes
  static const String tasks = '/tugas';
  static const String calendar = '/kalender';
  static const String home = '/beranda';
  static const String focusTimer = '/fokus-timer';
  static const String progress = '/progress';
  static const String profile = '/profile';
}