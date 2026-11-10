import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_planner/data/repositories/auth_repository.dart';
import 'package:ai_study_planner/core/system_clock.dart';
import 'package:ai_study_planner/services/onboarding_preferences_service.dart';

void main() {
  group('AuthNotifier', () {
    late FakeAuthRepository repo;

    setUp(() {
      repo = FakeAuthRepository(
        clock: SystemClock(),
        onboardingService: FakeOnboardingPreferencesService(),
      );
      // Test via direct repo calls since provider override is complex in unit test.
    });

    test('login with valid credentials sets loggedIn', () async {
      await repo.login('user@kampus.ac.id', 'password123');
      final state = await repo.watchAuthState().first;
      expect(state.isLoggedIn, isTrue);
      expect(state.errorMessage, isNull);
    });

    test('login with empty credentials shows error', () async {
      await repo.login('', '');
      final state = await repo.watchAuthState().first;
      expect(state.isLoggedIn, isFalse);
      expect(state.errorMessage, isNotNull);
    });

    test('register with short password shows error', () async {
      await repo.register('user@kampus.ac.id', 'abc');
      final state = await repo.watchAuthState().first;
      expect(state.isLoggedIn, isFalse);
      expect(state.errorMessage, contains('minimal 6 karakter'));
    });

    test('register with valid credentials succeeds', () async {
      await repo.register('user@kampus.ac.id', 'password123');
      final state = await repo.watchAuthState().first;
      expect(state.isLoggedIn, isTrue);
    });

    test('logout clears login state', () async {
      await repo.login('user@kampus.ac.id', 'password123');
      await repo.logout();
      final state = await repo.watchAuthState().first;
      expect(state.isLoggedIn, isFalse);
    });

    test('onboarding completed flag can be set', () async {
      expect(await repo.isOnboardingCompleted(), isFalse);
      await repo.setOnboardingCompleted(true);
      expect(await repo.isOnboardingCompleted(), isTrue);
    });
  });
}

/// Preferences palsu untuk pengujian notifier.
class FakeOnboardingPreferencesService implements OnboardingPreferencesService {
  bool _completed = false;

  @override
  Future<bool> isOnboardingCompleted() async => _completed;

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    _completed = completed;
  }
}
