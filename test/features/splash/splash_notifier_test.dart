import 'dart:async';

import 'package:ai_study_planner/core/clock.dart';
import 'package:ai_study_planner/core/session_policy.dart';
import 'package:ai_study_planner/features/splash/presentation/notifier/splash_notifier.dart';
import 'package:ai_study_planner/routing/session_keeper.dart';
import 'package:ai_study_planner/services/onboarding_preferences_service.dart';
import 'package:ai_study_planner/services/session_store.dart';
import 'package:flutter_test/flutter_test.dart';

/// Jam palsu dengan waktu tetap.
class _FakeClock implements Clock {
  _FakeClock(this.now_);

  @override
  DateTime now() => now_;

  late DateTime now_;
}

/// Perekam route tujuan.
class _Perekam {
  final List<String> rute = [];
}

void main() {
  final sekarang = DateTime(2026, 11, 10, 9, 0);
  const durasiMin = Duration(milliseconds: 40);
  const durasiMaks = Duration(milliseconds: 150);

  Future<(String, SessionKeeper)> jalankan({
    required OnboardingPreferencesService onboarding,
    required SessionStore store,
    _Perekam? perekamLuar,
  }) async {
    final clock = _FakeClock(sekarang);
    final keeper = SessionKeeper();
    final perekam = _Perekam();
    final notifier = SplashNotifier(
      sessionStore: store,
      onboardingService: onboarding,
      clock: clock,
      keeper: keeper,
      navigasi: perekam.rute.add,
      // ignore: avoid_redundant_argument_values
      durasiMinimal: durasiMin,
      // ignore: avoid_redundant_argument_values
      durasiMaksimal: durasiMaks,
    );
    await notifier.mulai();
    return (perekam.rute.single, keeper);
  }

  OnboardingPreferencesService onboarding(bool selesai) =>
      FakeOnboardingPreferencesService(completed: selesai);

  test('belum onboarding -> /onboarding', () async {
    final (rute, keeper) = await jalankan(
      onboarding: onboarding(false),
      store: InMemorySessionStore(),
    );
    expect(rute, '/onboarding');
    expect(keeper.decision, isA<NeedsOnboarding>());
  });

  test('tanpa token -> /login (pertama kali)', () async {
    final (rute, keeper) = await jalankan(
      onboarding: onboarding(true),
      store: InMemorySessionStore(),
    );
    expect(rute, '/login');
    final decision = keeper.decision! as NeedsLogin;
    expect(decision.reason, LoginReason.pertamaKali);
  });

  test('sesi valid (offline, lokal saja) -> /beranda dan touch dipanggil',
      () async {
    final store = InMemorySessionStore();
    final duaJamLalu = sekarang.subtract(const Duration(hours: 2));
    await store.catatLogin(email: 'bocil@kampus.ac.id', at: duaJamLalu);
    await store.simpanSesi(token: 't', lastActiveAt: duaJamLalu);

    final (rute, keeper) = await jalankan(
      onboarding: onboarding(true),
      store: store,
    );

    expect(rute, '/beranda');
    expect(keeper.decision, isA<Authenticated>());
    // Touch: dua jam > throttle satu jam -> lastActiveAt dinulis ulang.
    expect(await store.bacaLastActiveAt(), sekarang);
  });

  test('lastActiveAt 61 hari -> /login?reason=kedaluwarsa', () async {
    final store = InMemorySessionStore();
    final lama = sekarang.subtract(const Duration(days: 61));
    await store.catatLogin(email: 'bocil@kampus.ac.id', at: lama);
    await store.simpanSesi(token: 't', lastActiveAt: lama);

    final (rute, keeper) = await jalankan(
      onboarding: onboarding(true),
      store: store,
    );

    expect(rute, '/login?reason=kedaluwarsa');
    final decision = keeper.decision! as NeedsLogin;
    expect(decision.reason, LoginReason.kedaluwarsa);
  });

  test('durasi minimal terpenuhi sebelum navigasi', () async {
    final stopwatch = Stopwatch()..start();
    await jalankan(
      onboarding: onboarding(true),
      store: InMemorySessionStore(),
    );
    stopwatch.stop();
    expect(stopwatch.elapsed >= durasiMin, isTrue);
  });

  test('durasi maksimal: penyimpanan menggantung tetap navigasi tepat waktu',
      () async {
    final clock = _FakeClock(sekarang);
    final keeper = SessionKeeper();
    final perekam = _Perekam();

    final storeGantung = _StoreGantung();
    final stopwatch = Stopwatch()..start();
    final notifier = SplashNotifier(
      sessionStore: storeGantung,
      onboardingService: onboarding(true),
      clock: clock,
      keeper: keeper,
      navigasi: perekam.rute.add,
      durasiMinimal: durasiMin,
      durasiMaksimal: durasiMaks,
    );
    await notifier.mulai();
    stopwatch.stop();

    expect(perekam.rute.single, '/login');
    expect(stopwatch.elapsed <= durasiMaks + const Duration(milliseconds: 50),
        isTrue);
  });
}

/// Store yang bacaannya tidak pernah selesai (menggantung).
class _StoreGantung extends InMemorySessionStore {
  @override
  Future<String?> bacaToken() {
    return Completer<String?>().future;
  }
}
