import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/core/session_policy.dart';
import 'package:ai_study_planner/routing/routes.dart';

/// Fungsi murni: petakan keputusan sesi ke rute tujuan.
/// Dipakai splash dan test.
String ruteSesi(SessionDecision decision) {
  switch (decision) {
    case NeedsOnboarding():
      return AppRoutes.onboarding;
    case NeedsLogin(:final reason):
      return AppRoutes.loginDenganAlasan(reason);
    case Authenticated():
      return AppRoutes.beranda;
  }
}

/// Sumber kebenaran keputusan sesi untuk GoRouter (refreshListenable).
///
/// Splash mengisi [decision] lewat [tetapkan]; ApiClient memanggil
/// [kedaluwarsakan] saat respons 401 (termasuk code session_expired).
class SessionKeeper extends ChangeNotifier {
  SessionDecision? _decision;
  bool _splashSelesai = false;

  /// Keputusan terkini, atau null selama splash masih berjalan.
  SessionDecision? get decision => _decision;

  /// Benar bila splash sudah selesai menuju rute hasil keputusannya.
  bool get splashSelesai => _splashSelesai;

  /// Tetapkan hasil evaluasi splash dan tandai splash selesai.
  void tetapkan(SessionDecision decision) {
    _decision = decision;
    _splashSelesai = true;
    notifyListeners();
  }

  /// Sesi gugur di tengah pemakaian (401): giurkan login kedaluwarsa.
  /// Splash dianggap sudah lewat karena ini kejadian saat berjalan.
  void kedaluwarsakan() {
    _decision = const NeedsLogin(LoginReason.kedaluwarsa);
    _splashSelesai = true;
    notifyListeners();
  }
}

/// Provider SessionKeeper — di-override di bootstrap.
final sessionKeeperProvider = Provider<SessionKeeper>((ref) {
  throw UnimplementedError(
    'SessionKeeper belum di-override di bootstrap.',
  );
});
