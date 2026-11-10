import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_study_planner/app.dart';
import 'package:ai_study_planner/core/session_policy.dart';
import 'package:ai_study_planner/core/system_clock.dart';
import 'package:ai_study_planner/data/api/api_client.dart';
import 'package:ai_study_planner/data/repositories/auth_repository.dart';
import 'package:ai_study_planner/data/repositories/ai_repository.dart';
import 'package:ai_study_planner/data/repositories/course_repository.dart';
import 'package:ai_study_planner/data/repositories/fake_ai_repository.dart';
import 'package:ai_study_planner/data/repositories/fake_course_repository.dart';
import 'package:ai_study_planner/data/repositories/fake_focus_repository.dart';
import 'package:ai_study_planner/data/repositories/fake_session_repository.dart';
import 'package:ai_study_planner/data/repositories/fake_settings_repository.dart';
import 'package:ai_study_planner/data/repositories/fake_task_repository.dart';
import 'package:ai_study_planner/data/repositories/focus_repository.dart';
import 'package:ai_study_planner/data/repositories/remote_auth_repository.dart';
import 'package:ai_study_planner/data/repositories/remote_ai_repository.dart';
import 'package:ai_study_planner/data/repositories/remote_course_repository.dart';
import 'package:ai_study_planner/data/repositories/remote_focus_repository.dart';
import 'package:ai_study_planner/data/repositories/remote_session_repository.dart';
import 'package:ai_study_planner/data/repositories/remote_settings_repository.dart';
import 'package:ai_study_planner/data/repositories/remote_task_repository.dart';
import 'package:ai_study_planner/data/repositories/session_repository.dart';
import 'package:ai_study_planner/data/repositories/settings_repository.dart';
import 'package:ai_study_planner/data/repositories/task_repository.dart';
import 'package:ai_study_planner/features/splash/presentation/notifier/splash_notifier.dart';
import 'package:ai_study_planner/routing/session_keeper.dart';
import 'package:ai_study_planner/services/onboarding_preferences_service.dart';
import 'package:ai_study_planner/services/session_store.dart';

final _appClock = SystemClock();

/// Pilih sumber data lewat --dart-define=USE_FAKE=true|false.
/// Bila false, semua repository memakai implementasi remote (Dio).
const bool useFakeData = bool.fromEnvironment('USE_FAKE', defaultValue: true);

/// Milah respons 401 dari ApiClient ke SessionKeeper:
///
/// - 401 dari /auth/login atau /auth/register (kredensial salah) DIBIARKAN:
///   bukan kedaluwarsa; pesan kesalahan cukup tampil di form login.
/// - 401 dengan code `session_expired` -> hapus token & keaktifan di
///   aplikasi (surel terakhir disimpan) lalu keeper.kedaluwarsakan()
///   sehingga login tampil dengan banner kedaluwarsa.
/// - 401 lain pada endpoint terproteksi -> hapus sesi lalu login polos
///   (NeedsLogin pertamaKali, tanpa banner).
void sambungkanPengecualian401({
  required ApiClient apiClient,
  required SessionStore sessionStore,
  required SessionKeeper keeper,
}) {
  apiClient.addUnauthorizedListener((info) {
    final diEndpointAuth = info.path.endsWith('/auth/login') ||
        info.path.endsWith('/auth/register');
    if (diEndpointAuth) return;

    if (info.code == 'session_expired') {
      unawaited(
        sessionStore.hapusSesi().then((_) => keeper.kedaluwarsakan()),
      );
      return;
    }

    unawaited(
      sessionStore.hapusSesi().then(
        (_) => keeper.tetapkan(const NeedsLogin(LoginReason.pertamaKali)),
      ),
    );
  });
}

Future<ProviderScope> bootstrap() async {
  final prefs = await SharedPreferences.getInstance();
  final onboardingService = SharedPreferencesOnboardingService(prefs);

  final apiClient = ApiClient();
  await apiClient.warmTokenCache();

  // Satu sumber token bersama ApiClient; lastActiveAt di SharedPreferences.
  final sessionStore = SharedPreferencesSessionStore(
    prefs: prefs,
    tokenStorage: apiClient.tokenStorage,
  );

  final sessionKeeper = SessionKeeper();
  sambungkanPengecualian401(
    apiClient: apiClient,
    sessionStore: sessionStore,
    keeper: sessionKeeper,
  );

  late final AuthRepository authRepo;
  late final CourseRepository courseRepo;
  late final TaskRepository taskRepo;
  late final SessionRepository sessionRepo;
  late final FocusRepository focusRepo;
  late final SettingsRepository settingsRepo;
  late final AiRepository aiRepo;

  if (useFakeData) {
    authRepo = FakeAuthRepository(
      clock: _appClock,
      onboardingService: onboardingService,
      sessionStore: sessionStore,
    );
    courseRepo = FakeCourseRepository(clock: _appClock);
    taskRepo = FakeTaskRepository(clock: _appClock);
    sessionRepo = FakeSessionRepository(clock: _appClock);
    focusRepo = FakeFocusRepository(clock: _appClock);
    settingsRepo = FakeSettingsRepository();
    aiRepo = FakeAiRepository(clock: _appClock);
  } else {
    authRepo = RemoteAuthRepository(
      apiClient,
      sessionStore: sessionStore,
      clock: _appClock,
    );
    courseRepo = RemoteCourseRepository(dio: apiClient.dio);
    taskRepo = RemoteTaskRepository(dio: apiClient.dio);
    sessionRepo = RemoteSessionRepository(dio: apiClient.dio);
    focusRepo = RemoteFocusRepository(dio: apiClient.dio);
    settingsRepo = RemoteSettingsRepository(dio: apiClient.dio);
    aiRepo = RemoteAiRepository(dio: apiClient.dio);
  }

  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(authRepo),
      onboardingServiceProvider.overrideWithValue(onboardingService),
      sessionStoreProvider.overrideWithValue(sessionStore),
      sessionKeeperProvider.overrideWithValue(sessionKeeper),
      splashWarmUpProvider.overrideWithValue(
        () => apiClient.warmTokenCache(),
      ),
      courseRepositoryProvider.overrideWith(
        (ref) => courseRepo,
      ),
      taskRepositoryProvider.overrideWith(
        (ref) => taskRepo,
      ),
      sessionRepositoryProvider.overrideWith(
        (ref) => sessionRepo,
      ),
      focusRepositoryProvider.overrideWith(
        (ref) => focusRepo,
      ),
      settingsRepositoryProvider.overrideWith(
        (ref) => settingsRepo,
      ),
      aiRepositoryProvider.overrideWith(
        (ref) => aiRepo,
      ),
    ],
    child: const MyApp(),
  );
}
