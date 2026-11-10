import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_planner/core/session_policy.dart';

void main() {
  const policy = SessionPolicy();

  final onboardingSelesai = DateTime(2026, 1, 1, 8, 0);

  SessionDecision evaluateWith(DateTime now, DateTime? lastActive) {
    return policy.evaluate(
      now: now,
      lastActiveAt: lastActive,
      hasToken: true,
      onboardingDone: true,
    );
  }

  group('SessionPolicy', () {
    test('belum onboarding -> NeedsOnboarding walau sudah punya token', () {
      final decision = policy.evaluate(
        now: onboardingSelesai,
        lastActiveAt: onboardingSelesai,
        hasToken: true,
        onboardingDone: false,
      );
      expect(decision, isA<NeedsOnboarding>());
    });

    test('tanpa token -> NeedsLogin(pertamaKali)', () {
      final decision = policy.evaluate(
        now: onboardingSelesai,
        lastActiveAt: null,
        hasToken: false,
        onboardingDone: true,
      );
      expect(decision, isA<NeedsLogin>());
      expect((decision as NeedsLogin).reason, LoginReason.pertamaKali);
    });

    test('onboarding belum selesai lebih dipentingkan daripada token', () {
      final decision = policy.evaluate(
        now: onboardingSelesai,
        lastActiveAt: null,
        hasToken: false,
        onboardingDone: false,
      );
      expect(decision, isA<NeedsOnboarding>());
    });

    test('tepat 60 hari -> masih Authenticated', () {
      final decision = evaluateWith(
        onboardingSelesai.add(SessionPolicy.maxIdle),
        onboardingSelesai,
      );
      expect(decision, isA<Authenticated>());
    });

    test('59 hari 23 jam -> Authenticated', () {
      final lastActive = onboardingSelesai;
      final now = lastActive.add(
        const Duration(days: 59, hours: 23),
      );
      expect(evaluateWith(now, lastActive), isA<Authenticated>());
    });

    test('61 hari -> NeedsLogin(kedaluwarsa)', () {
      final lastActive = onboardingSelesai;
      final now = lastActive.add(const Duration(days: 61));
      final decision = evaluateWith(now, lastActive);
      expect(decision, isA<NeedsLogin>());
      expect((decision as NeedsLogin).reason, LoginReason.kedaluwarsa);
    });

    test('tepat 60 hari + 1 milidetik -> kedaluwarsa', () {
      final lastActive = onboardingSelesai;
      final now = lastActive.add(
        SessionPolicy.maxIdle + const Duration(milliseconds: 1),
      );
      expect(evaluateWith(now, lastActive), isA<NeedsLogin>());
    });

    test('lastActiveAt kosong tapi punya token -> kedaluwarsa', () {
      final decision = evaluateWith(onboardingSelesai, null);
      expect(decision, isA<NeedsLogin>());
      expect((decision as NeedsLogin).reason, LoginReason.kedaluwarsa);
    });

    test('jam mundur (now lebih awal dari lastActiveAt) -> tetap valid', () {
      final lastActive = onboardingSelesai;
      final now = lastActive.subtract(const Duration(days: 90));
      expect(evaluateWith(now, lastActive), isA<Authenticated>());
    });
  });
}
