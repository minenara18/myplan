import 'package:ai_study_planner/core/clock.dart';
import 'package:ai_study_planner/core/system_clock.dart';
import 'package:ai_study_planner/data/repositories/ai_repository.dart';
import 'package:ai_study_planner/data/repositories/auth_repository.dart';
import 'package:ai_study_planner/data/repositories/course_repository.dart';
import 'package:ai_study_planner/data/repositories/fake_ai_repository.dart';
import 'package:ai_study_planner/data/repositories/fake_course_repository.dart';
import 'package:ai_study_planner/data/repositories/fake_focus_repository.dart';
import 'package:ai_study_planner/data/repositories/fake_session_repository.dart';
import 'package:ai_study_planner/data/repositories/fake_settings_repository.dart';
import 'package:ai_study_planner/data/repositories/fake_task_repository.dart';
import 'package:ai_study_planner/data/repositories/focus_repository.dart';
import 'package:ai_study_planner/data/repositories/session_repository.dart';
import 'package:ai_study_planner/data/repositories/settings_repository.dart';
import 'package:ai_study_planner/data/repositories/task_repository.dart';
import 'package:ai_study_planner/routing/session_keeper.dart';
import 'package:ai_study_planner/services/onboarding_preferences_service.dart';
import 'package:ai_study_planner/services/session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Jam palsu dengan tanggal tetap agar test deterministik.
class FakeClock implements Clock {
  FakeClock(this.fixedNow);

  final DateTime fixedNow;

  @override
  DateTime now() => fixedNow;
}

/// Menyiapkan SharedPreferences mock dan mengembalikan scope provider
/// dengan semua repositori fake + jam tetap.
/// Semua test layar memakai ini agar layar dirender dengan data fake.
class ScreenHarness {
  ScreenHarness({DateTime? fixedNow})
      : clock = FakeClock(
          fixedNow ?? DateTime(2026, 11, 9, 10, 0),
        );

  final FakeClock clock;
  late SharedPreferencesOnboardingService onboardingService;

  late FakeAuthRepository authRepo;
  late FakeCourseRepository courseRepo;
  late FakeTaskRepository taskRepo;
  late FakeSessionRepository sessionRepo;
  late FakeFocusRepository focusRepo;
  late FakeSettingsRepository settingsRepo;
  late FakeAiRepository aiRepo;
  late InMemorySessionStore sessionStore;
  late SessionKeeper sessionKeeper;

  List<Override> overrides() => [
        clockProvider.overrideWithValue(clock),
        authRepositoryProvider.overrideWithValue(authRepo),
        onboardingServiceProvider.overrideWithValue(onboardingService),
        sessionStoreProvider.overrideWithValue(sessionStore),
        sessionKeeperProvider.overrideWithValue(sessionKeeper),
        courseRepositoryProvider.overrideWithValue(courseRepo),
        taskRepositoryProvider.overrideWithValue(taskRepo),
        sessionRepositoryProvider.overrideWithValue(sessionRepo),
        focusRepositoryProvider.overrideWithValue(focusRepo),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        aiRepositoryProvider.overrideWithValue(aiRepo),
      ];

  /// Harus dipanggil (await) sebelum pumpWidget.
  Future<void> init() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    onboardingService = SharedPreferencesOnboardingService(prefs);
    sessionStore = InMemorySessionStore();
    sessionKeeper = SessionKeeper();

    authRepo = FakeAuthRepository(
      clock: clock,
      onboardingService: onboardingService,
      sessionStore: sessionStore,
    );
    courseRepo = FakeCourseRepository(clock: clock);
    taskRepo = FakeTaskRepository(clock: clock);
    sessionRepo = FakeSessionRepository(clock: clock);
    focusRepo = FakeFocusRepository(clock: clock);
    settingsRepo = FakeSettingsRepository();
    aiRepo = FakeAiRepository(clock: clock);
  }
}

/// Pemapar baku: view ukuran ponsel umum + skala teks yang bisa diatur.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  required List<Override> overrides,
  double textScale = 1.0,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(textScale),
        ),
        child: MaterialApp(home: screen),
      ),
    ),
  );
  // Settle: stream fake selesai on microtask; animasi chart selesai.
  await tester.pump();
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

/// Tidak ada exception overflow tersisa dari frame-frame sebelumnya.
/// Tidak ada exception overflow tersisa dari frame-frame sebelumnya.
void expectNoOverflow(WidgetTester tester) {
  expect(tester.takeException(), isNull);
}
