import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_study_planner/features/ai_planner/presentation/screen/ai_planner_screen.dart';
import 'package:ai_study_planner/features/ai_planner/presentation/screen/ringkas_materi_screen.dart';
import 'package:ai_study_planner/features/auth/presentation/screen/login_screen.dart';
import 'package:ai_study_planner/features/auth/presentation/screen/register_screen.dart';
import 'package:ai_study_planner/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:ai_study_planner/features/calendar/presentation/screen/calendar_screen.dart';
import 'package:ai_study_planner/features/focus_timer/presentation/screen/focus_timer_screen.dart';
import 'package:ai_study_planner/features/home/presentation/screen/home_screen.dart';
import 'package:ai_study_planner/features/onboarding/presentation/screen/onboarding_screen.dart';
import 'package:ai_study_planner/features/profile/presentation/screen/profile_screen.dart';
import 'package:ai_study_planner/features/progress/presentation/screen/progress_screen.dart';
import 'package:ai_study_planner/features/tasks/presentation/screen/add_edit_task_screen.dart';
import 'package:ai_study_planner/features/tasks/presentation/screen/task_detail_screen.dart';
import 'package:ai_study_planner/features/tasks/presentation/screen/tasks_screen.dart';
import 'package:ai_study_planner/routing/auth_provider.dart';
import 'package:ai_study_planner/routing/redirect_guard.dart';
import 'package:ai_study_planner/routing/routes.dart';
import 'package:ai_study_planner/routing/screens/not_found_screen.dart';
import 'package:ai_study_planner/theme/components/glass_bottom_bar.dart';

/// Provider GoRouter: dibangun ulang saat status auth berubah sehingga
/// redirect guard selalu membaca status terkini (fungsi murni).
/// Rute dideklarasikan di sini agar glue lintas-fitur (menandai onboarding
/// selesai melalui AuthNotifier) hidup di lapisan routing, bukan di fitur.
final goRouterProvider = Provider<GoRouter>((ref) {
  final status = ref.watch(authStatusProvider);

  return GoRouter(
    redirect: (context, state) => redirectGuard(
      currentRoute: state.matchedLocation,
      auth: status,
    ),
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.beranda,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.kalender,
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.ai,
                builder: (context, state) => const AiPlannerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.progres,
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profil,
                builder: (context, state) => ProfileScreen(
                  // Glue lintas fitur milik routing: fitur profile
                  // tidak mengimpor fitur auth.
                  onLogout: () =>
                      ref.read(authNotifierProvider.notifier).logout(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => OnboardingScreen(
          // Glue lintas fitur milik routing: fitur onboarding tidak
          // mengimpor fitur auth.
          onSelesai: () {
            ref
                .read(authNotifierProvider.notifier)
                .setOnboardingCompleted(true);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.fokus,
        builder: (context, state) => const FocusTimerScreen(),
      ),
      GoRoute(
        path: AppRoutes.tasks,
        builder: (context, state) => const TasksScreen(),
      ),
      GoRoute(
        path: AppRoutes.tugasBaru,
        builder: (context, state) => const AddEditTaskScreen(),
      ),
      GoRoute(
        path: '/tugas/:id',
        builder: (context, state) => TaskDetailScreen(
          tugasId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.ringkasMateri,
        builder: (context, state) => const RingkasMateriScreen(),
      ),
    ],
  );
});

/// Scaffold dengan GlassBottomBar sebagai navigasi shell.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: GlassBottomBar(
        selectedIndex: navigationShell.currentIndex,
        onChanged: (index) => navigationShell.goBranch(index),
      ),
    );
  }
}
