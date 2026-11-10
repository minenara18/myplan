import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_study_planner/app.dart';
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
import 'package:ai_study_planner/services/onboarding_preferences_service.dart';

final _appClock = SystemClock();

/// Pilih sumber data lewat --dart-define=USE_FAKE=true|false.
/// Bila false, semua repository memakai implementasi remote (Dio).
const bool useFakeData = bool.fromEnvironment('USE_FAKE', defaultValue: true);

Future<ProviderScope> bootstrap() async {
  final prefs = await SharedPreferences.getInstance();
  final onboardingService = SharedPreferencesOnboardingService(prefs);

  final apiClient = ApiClient();
  await apiClient.warmTokenCache();

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
    );
    courseRepo = FakeCourseRepository(clock: _appClock);
    taskRepo = FakeTaskRepository(clock: _appClock);
    sessionRepo = FakeSessionRepository(clock: _appClock);
    focusRepo = FakeFocusRepository(clock: _appClock);
    settingsRepo = FakeSettingsRepository();
    aiRepo = FakeAiRepository(clock: _appClock);
  } else {
    authRepo = RemoteAuthRepository(apiClient);
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
