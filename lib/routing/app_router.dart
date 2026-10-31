import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_study_planner/theme/components/glass_bottom_bar.dart';
import 'package:ai_study_planner/routing/auth_provider.dart';
import 'package:ai_study_planner/routing/redirect_guard.dart';
import 'package:ai_study_planner/routing/routes.dart';
import 'package:ai_study_planner/routing/screens/beranda_screen.dart';
import 'package:ai_study_planner/routing/screens/fokus_screen.dart';
import 'package:ai_study_planner/routing/screens/login_screen.dart';
import 'package:ai_study_planner/routing/screens/not_found_screen.dart';
import 'package:ai_study_planner/routing/screens/onboarding_screen.dart';
import 'package:ai_study_planner/routing/screens/progres_screen.dart';
import 'package:ai_study_planner/routing/screens/profil_screen.dart';
import 'package:ai_study_planner/routing/screens/register_screen.dart';
import 'package:ai_study_planner/routing/screens/tugas_baru_screen.dart';
import 'package:ai_study_planner/routing/screens/tugas_detail_screen.dart';
import 'package:ai_study_planner/features/ai_planner/presentation/screen/ai_planner_screen.dart';
import 'package:ai_study_planner/features/ai_planner/presentation/screen/ringkas_materi_screen.dart';
import 'package:ai_study_planner/features/calendar/presentation/screen/calendar_screen.dart';
import 'package:ai_study_planner/features/focus_timer/presentation/screen/focus_timer_screen.dart';
import 'package:ai_study_planner/features/home/presentation/screen/home_screen.dart';
import 'package:ai_study_planner/features/progress/presentation/screen/progress_screen.dart';
import 'package:ai_study_planner/features/profile/presentation/screen/profile_screen.dart';
import 'package:ai_study_planner/features/tasks/presentation/screen/tasks_screen.dart';

// Instance palsu (temporary fake) untuk status auth.
final _fakeAuth = FakeAuthProvider();

/// GoRouter konfigurasi utama.
/// Shell menggunakan StatefulShellRoute.indexedStack dengan 5 cabang.
/// Rute di luar shell: /onboarding, /login, /register, /fokus, /tugas/baru, /tugas/:id.
/// Identitas selalu lewat path param, bukan state.extra.
final goRouter = GoRouter(
  redirect: (context, state) => redirectGuard(
    currentRoute: state.matchedLocation,
    auth: _fakeAuth.status,
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
              builder: (context, state) => const BerandaScreen(),
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
              builder: (context, state) => const ProgresScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profil,
              builder: (context, state) => const ProfilScreen(),
            ),
          ],
        ),
      ],
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
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.fokus,
      builder: (context, state) => const FokusScreen(),
    ),
    GoRoute(
      path: AppRoutes.tugasBaru,
      builder: (context, state) => const TugasBaruScreen(),
    ),
    GoRoute(
      path: AppRoutes.ringkasMateri,
      builder: (context, state) => const RingkasMateriScreen(),
    ),
    GoRoute(
      path: '/tugas/:id',
      builder: (context, state) => TugasDetailScreen(
        tugasId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: AppRoutes.tasks,
      builder: (context, state) => const TasksScreen(),
    ),
    GoRoute(
      path: AppRoutes.calendar,
      builder: (context, state) => const CalendarScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.focusTimer,
      builder: (context, state) => const FocusTimerScreen(),
    ),
    GoRoute(
      path: AppRoutes.progress,
      builder: (context, state) => const ProgressScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);

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