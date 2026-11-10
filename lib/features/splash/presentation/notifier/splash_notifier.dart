import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_study_planner/core/clock.dart';
import 'package:ai_study_planner/core/session_policy.dart';
import 'package:ai_study_planner/core/system_clock.dart';
import 'package:ai_study_planner/routing/session_keeper.dart';
import 'package:ai_study_planner/services/onboarding_preferences_service.dart';
import 'package:ai_study_planner/services/session_store.dart';

/// Notifier alur splash: putuskan rute tanpa jaringan (offline-first),
/// perpanjang sesi bila masih hidup, lalu navigasi.
///
/// [navigasi], [warmUp], waktu, dan durasi disuntik agar mudah diuji.
class SplashNotifier {
  SplashNotifier({
    required this.sessionStore,
    required this.onboardingService,
    required this.clock,
    required this.keeper,
    required this.navigasi,
    this.durasiMinimal = const Duration(milliseconds: 1200),
    this.durasiMaksimal = const Duration(milliseconds: 4000),
    Future<void> Function()? warmUp,
  }) : _warmUp = warmUp;

  final SessionStore sessionStore;
  final OnboardingPreferencesService onboardingService;
  final Clock clock;
  final SessionKeeper keeper;

  /// Navigasi hasil keputusan (nyata: context.go; test: perekam).
  final void Function(String route) navigasi;

  /// Splash tampil minimal selama ini sebelum navigasi.
  final Duration durasiMinimal;

  /// Batas keras: navigasi tetap terjadi walaupun penyimpanan lambat.
  final Duration durasiMaksimal;

  final Future<void> Function()? _warmUp;

  /// Alur utama splash: evaluasi keputusan, touch bila terautentikasi,
  /// publikasikan ke keeper, pastikan durasi minimal, lalu navigasi.
  Future<void> mulai() async {
    // Warm-up tidak memblokir dan dibungkus timeout sendiri.
    final warmUp = _warmUp;
    if (warmUp != null) {
      unawaited(warmUp().timeout(durasiMaksimal, onTimeout: () {}));
    }

    final stopwatch = Stopwatch()..start();
    final decision = await _keputusanDenganBatas();

    if (decision is Authenticated) {
      await sessionStore.touch(clock.now());
    }
    keeper.tetapkan(decision);

    final sisa = durasiMinimal - stopwatch.elapsed;
    if (sisa > Duration.zero) {
      await Future<void>.delayed(sisa);
    }
    navigasi(ruteSesi(decision));
  }

  /// Evaluasi lokal: baca store, hitung keputusan. Bacaan lokal hampir
  /// selalu cepat; batas [durasiMaksimal] hanya pembatas keras.
  Future<SessionDecision> _keputusanDenganBatas() {
    return _keputusan().timeout(
      durasiMaksimal,
      onTimeout: () => const NeedsLogin(LoginReason.pertamaKali),
    );
  }

  Future<SessionDecision> _keputusan() async {
    final token = await sessionStore.bacaToken();
    final lastActiveAt = await sessionStore.bacaLastActiveAt();
    final onboardingDone = await onboardingService.isOnboardingCompleted();
    return const SessionPolicy().evaluate(
      now: clock.now(),
      lastActiveAt: lastActiveAt,
      hasToken: token != null && token.isNotEmpty,
      onboardingDone: onboardingDone,
    );
  }
}

/// Callback warm-up. Nyata: pemanasan cache token ApiClient.
final splashWarmUpProvider = Provider<Future<void> Function()>(
  (ref) => () async {},
);

/// Pabrik SplashNotifier: layar memanggil dengan BuildContext agar
/// navigasi default memakai context.go; test menyuntikkan perekam.
final splashNotifierFactoryProvider =
    Provider<SplashNotifier Function(BuildContext)>((ref) {
  return (context) {
    return SplashNotifier(
      sessionStore: ref.read(sessionStoreProvider),
      onboardingService: ref.read(onboardingServiceProvider),
      clock: ref.read(clockProvider),
      keeper: ref.read(sessionKeeperProvider),
      navigasi: (route) {
        if (context.mounted) context.go(route);
      },
      warmUp: ref.read(splashWarmUpProvider),
    );
  };
});
