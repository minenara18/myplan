import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_study_planner/l10n/app_localizations.dart';
import 'package:ai_study_planner/theme/components/error_retry_card.dart';
import 'package:ai_study_planner/theme/components/progress_ring.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';
import 'package:ai_study_planner/features/home/presentation/notifier/home_notifier.dart';
import 'package:ai_study_planner/features/home/presentation/widgets/streak_badge_widget.dart';
import 'package:ai_study_planner/features/home/presentation/widgets/quick_actions_widget.dart';
import 'package:ai_study_planner/routing/routes.dart';

/// Layar beranda dengan sapaan serif, progres, kartu fokus, chip mata pelajaran, dan aksi cepat.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(homeNotifierProvider);
    final state = notifier.state;

    return Scaffold(
      body: SafeArea(
        child: switch (state) {
          HomeLoading() => const Center(child: CircularProgressIndicator()),
          HomeError(:final message) => ErrorRetryCard(
              message: message,
              onRetry: ref.read(homeNotifierProvider.notifier).load,
            ),
          HomeContent(:final todayProgress, :final streak) =>
            _HomeContent(todayProgress: todayProgress, streak: streak),
        },
      ),
    );
  }
}

/// Isi beranda. Kelas terpisah agar konst-able per bagian dan
/// dependensi state eksplisit.
class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.todayProgress,
    required this.streak,
  });

  final double todayProgress;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            l10n('Greeting_nama'),
            style: TextStyle(
              fontFamily: 'DM Serif Display',
              fontSize: 32,
              color: ColorTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n('HomeSubtitle'),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: ColorTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n('TodayProgress'),
                  style: TextStyle(
                    fontFamily: 'DM Serif Display',
                    fontSize: 20,
                    color: ColorTokens.textPrimary,
                  ),
                ),
              ),
              Text(
                '${(todayProgress * 100).round()}%',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: ColorTokens.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ProgressRing(
            value: todayProgress,
            size: 64,
            strokeWidth: 6,
          ),
          const SizedBox(height: 24),
          _FocusCard(
            onMulai: () => context.go(AppRoutes.fokus),
          ),
          const SizedBox(height: 24),
          Text(
            l10n('Subjects'),
            style: TextStyle(
              fontFamily: 'DM Serif Display',
              fontSize: 20,
              color: ColorTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const _SubjectRow(),
          const SizedBox(height: 24),
          Text(
            l10n('QuickActions'),
            style: TextStyle(
              fontFamily: 'DM Serif Display',
              fontSize: 20,
              color: ColorTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const QuickActionsWidget(),
          const SizedBox(height: 24),
          StreakBadgeWidget(streak: streak),
        ],
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({required this.onMulai});

  final VoidCallback onMulai;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorTokens.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ColorTokens.moonstone.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.flag,
                  color: ColorTokens.moonstone, semanticLabel: 'Fokus'),
              const SizedBox(width: 8),
              Expanded(
                // Membungkus di lebar kartu, tanpa potongan,
                // aman pada skala teks besar.
                child: Text(
                  l10n('FocusToday'),
                  style: TextStyle(
                    fontFamily: 'DM Serif Display',
                    fontSize: 20,
                    color: ColorTokens.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: 20,
                  color: ColorTokens.moonstone,
                  semanticLabel: 'Waktu'),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n('NextSession'),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: ColorTokens.textSecondary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.play_arrow,
                    color: ColorTokens.moonstone),
                tooltip: l10n('StartSession'),
                onPressed: onMulai,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          SubjectChipWidget(label: 'Pemrograman Mobile'),
          SubjectChipWidget(label: 'Basis Data'),
          SubjectChipWidget(label: 'Jaringan Komputer'),
          SubjectChipWidget(label: 'Kecerdasan Buatan'),
        ],
      ),
    );
  }
}

class SubjectChipWidget extends StatelessWidget {
  const SubjectChipWidget({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ColorTokens.vanilla.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorTokens.vanilla,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: ColorTokens.textPrimary,
        ),
      ),
    );
  }
}
