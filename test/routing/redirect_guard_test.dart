import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_planner/core/session_policy.dart';
import 'package:ai_study_planner/routing/redirect_guard.dart';
import 'package:ai_study_planner/routing/routes.dart';
import 'package:ai_study_planner/routing/session_keeper.dart';

void main() {
  group('Rute Sesi (ruteSesi)', () {
    test('NeedsOnboarding -> /onboarding', () {
      expect(ruteSesi(const NeedsOnboarding()), AppRoutes.onboarding);
    });

    test('NeedsLogin(pertamaKali) -> /login', () {
      expect(
        ruteSesi(const NeedsLogin(LoginReason.pertamaKali)),
        AppRoutes.login,
      );
    });

    test('NeedsLogin(kedaluwarsa) -> /login?reason=kedaluwarsa', () {
      expect(
        ruteSesi(const NeedsLogin(LoginReason.kedaluwarsa)),
        '/login?reason=kedaluwarsa',

      );
    });

    test('Authenticated -> /beranda', () {
      expect(ruteSesi(const Authenticated()), AppRoutes.beranda);
    });
  });

  group('SessionKeeper', () {
    late SessionKeeper keeper;

    setUp(() {
      keeper = SessionKeeper();
    });

    test('awal: decision null dan splash belum selesai', () {
      expect(keeper.decision, isNull);
      expect(keeper.splashSelesai, isFalse);
    });

    test('tetapkan mengisi decision dan menandai splash selesai', () {
      keeper.tetapkan(const Authenticated());
      expect(keeper.decision, isA<Authenticated>());
      expect(keeper.splashSelesai, isTrue);
    });

    test('tetapkan memberi tahu listener', () {
      var notifikasi = 0;
      keeper.addListener(() => notifikasi++);
      keeper.tetapkan(const Authenticated());
      expect(notifikasi, 1);
    });

    test('kedaluwarsakan membuat NeedsLogin(kedaluwarsa)', () {
      keeper.tetapkan(const Authenticated());
      keeper.kedaluwarsakan();
      final decision = keeper.decision!;
      expect(decision, isA<NeedsLogin>());
      expect((decision as NeedsLogin).reason, LoginReason.kedaluwarsa);
      expect(keeper.splashSelesai, isTrue);
    });
  });

  group('Redirect Guard (decision)', () {
    test('decision null dan bukan di /splash -> dipaksa ke /splash', () {
      final hasil = redirectGuard(
        currentRoute: AppRoutes.beranda,
        decision: null,
        splashSudahMenuju: false,
      );
      expect(hasil, AppRoutes.splash);
    });

    test('decision null dan sudah di /splash -> null (splash berjalan)', () {
      final hasil = redirectGuard(
        currentRoute: AppRoutes.splash,
        decision: null,
        splashSudahMenuju: false,
      );
      expect(hasil, isNull);
    });

    test(
        'decision null tapi splash sudah menuju -> null (navigasi sedang jalan)',
        () {
      final hasil = redirectGuard(
        currentRoute: AppRoutes.login,
        decision: null,
        splashSudahMenuju: true,
      );
      expect(hasil, isNull);
    });
  });

  group('Redirect Guard (NeedsOnboarding)', () {
    final decision = const NeedsOnboarding();

    test('di /beranda -> dipaksa ke /onboarding', () {
      expect(
        redirectGuard(
          currentRoute: AppRoutes.beranda,
          decision: decision,
          splashSudahMenuju: true,
        ),
        AppRoutes.onboarding,
      );
    });

    test('di /onboarding -> null', () {
      expect(
        redirectGuard(
          currentRoute: AppRoutes.onboarding,
          decision: decision,
          splashSudahMenuju: true,
        ),
        isNull,
      );
    });

    test('di /login dan /register -> null (boleh menengok auth)', () {
      expect(
        redirectGuard(
          currentRoute: AppRoutes.login,
          decision: decision,
          splashSudahMenuju: true,
        ),
        isNull,
      );
      expect(
        redirectGuard(
          currentRoute: AppRoutes.register,
          decision: decision,
          splashSudahMenuju: true,
        ),
        isNull,
      );
    });
  });

  group('Redirect Guard (NeedsLogin)', () {
    test('pertamaKali di /beranda -> /login', () {
      final hasil = redirectGuard(
        currentRoute: AppRoutes.beranda,
        decision: const NeedsLogin(LoginReason.pertamaKali),
        splashSudahMenuju: true,
      );
      expect(hasil, AppRoutes.login);
    });

    test('kedaluwarsa di /beranda -> /login?reason=kedaluwarsa', () {
      final hasil = redirectGuard(
        currentRoute: AppRoutes.beranda,
        decision: const NeedsLogin(LoginReason.kedaluwarsa),
        splashSudahMenuju: true,
      );
      expect(hasil, '/login?reason=kedaluwarsa');
    });

    test('di /onboarding (tidak diizinkan untuk login) -> ke /login', () {
      final hasil = redirectGuard(
        currentRoute: AppRoutes.onboarding,
        decision: const NeedsLogin(LoginReason.pertamaKali),
        splashSudahMenuju: true,
      );
      expect(hasil, AppRoutes.login);
    });

    test('di /login -> null', () {
      expect(
        redirectGuard(
          currentRoute: AppRoutes.login,
          decision: const NeedsLogin(LoginReason.kedaluwarsa),
          splashSudahMenuju: true,
        ),
        isNull,
      );
    });

    test('di /register -> null', () {
      expect(
        redirectGuard(
          currentRoute: AppRoutes.register,
          decision: const NeedsLogin(LoginReason.pertamaKali),
          splashSudahMenuju: true,
        ),
        isNull,
      );
    });
  });

  group('Redirect Guard (Authenticated)', () {
    final decision = const Authenticated();

    test('buka /onboarding -> /beranda', () {
      expect(
        redirectGuard(
          currentRoute: AppRoutes.onboarding,
          decision: decision,
          splashSudahMenuju: true,
        ),
        AppRoutes.beranda,
      );
    });

    test('login tidak bisa dibuka saat terautentikasi -> /beranda', () {
      expect(
        redirectGuard(
          currentRoute: AppRoutes.login,
          decision: decision,
          splashSudahMenuju: true,
        ),
        AppRoutes.beranda,
      );
    });

    test('buka /register -> /beranda', () {
      expect(
        redirectGuard(
          currentRoute: AppRoutes.register,
          decision: decision,
          splashSudahMenuju: true,
        ),
        AppRoutes.beranda,
      );
    });

    test('di /beranda -> null (boleh lanjut)', () {
      expect(
        redirectGuard(
          currentRoute: AppRoutes.beranda,
          decision: decision,
          splashSudahMenuju: true,
        ),
        isNull,
      );
    });

    test('/splash tidak pernah di-redirect bahkan saat Authenticated', () {
      expect(
        redirectGuard(
          currentRoute: AppRoutes.splash,
          decision: decision,
          splashSudahMenuju: true,
        ),
        isNull,
      );
    });
  });
}
