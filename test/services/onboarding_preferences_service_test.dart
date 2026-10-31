import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_planner/services/onboarding_preferences_service.dart';

void main() {
  group('FakeOnboardingPreferencesService', () {
    test('default is not completed', () async {
      final service = FakeOnboardingPreferencesService();
      expect(await service.isOnboardingCompleted(), isFalse);
    });

    test('set and get completed flag', () async {
      final service = FakeOnboardingPreferencesService();
      await service.setOnboardingCompleted(true);
      expect(await service.isOnboardingCompleted(), isTrue);
      await service.setOnboardingCompleted(false);
      expect(await service.isOnboardingCompleted(), isFalse);
    });
  });
}

/// Preferences palsu untuk pengujian.
class FakeOnboardingPreferencesService
    implements OnboardingPreferencesService {
  bool _completed = false;

  @override
  Future<bool> isOnboardingCompleted() async => _completed;

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    _completed = completed;
  }
}