import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/theme/components/error_retry_card.dart';
import 'package:ai_study_planner/theme/components/progress_ring.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';
import 'package:ai_study_planner/features/home/presentation/notifier/home_notifier.dart';
import 'package:ai_study_planner/features/home/presentation/widgets/streak_badge_widget.dart';
import 'package:ai_study_planner/features/home/presentation/widgets/quick_actions_widget.dart';

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
          HomeContent() => _homeContent(context, state),
        },
      ),
    );
  }

  Widget _homeContent(BuildContext context, HomeContent state) {
    return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Halo, Pengguna',
                style: TextStyle(
                  fontFamily: 'DM Serif Display',
                  fontSize: 32,
                  color: ColorTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selamat belajar hari ini!',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: ColorTokens.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Progres Hari Ini',
                    style: TextStyle(
                      fontFamily: 'DM Serif Display',
                      fontSize: 20,
                      color: ColorTokens.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${state.todayProgress * 100}%',
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
                value: state.todayProgress,
                size: 64,
                strokeWidth: 6,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
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
                      children: [
                        const Icon(Icons.flag, color: ColorTokens.moonstone),
                        const SizedBox(width: 8),
                        Text(
                          'Fokus Hari Ini',
                          style: TextStyle(
                            fontFamily: 'DM Serif Display',
                            fontSize: 20,
                            color: ColorTokens.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 20, color: ColorTokens.moonstone),
                        const SizedBox(width: 8),
                        Text(
                          'Sesi berikutnya: 14:00',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: ColorTokens.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.play_arrow, color: ColorTokens.moonstone),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Mata Pelajaran',
                style: TextStyle(
                  fontFamily: 'DM Serif Display',
                  fontSize: 20,
                  color: ColorTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    SubjectChipWidget(label: 'Pemrograman Mobile'),
                    SubjectChipWidget(label: 'Basis Data'),
                    SubjectChipWidget(label: 'Jaringan Komputer'),
                    SubjectChipWidget(label: 'Kecerdasan Buatan'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Aksi Cepat',
                style: TextStyle(
                  fontFamily: 'DM Serif Display',
                  fontSize: 20,
                  color: ColorTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const QuickActionsWidget(),
              const SizedBox(height: 24),
              StreakBadgeWidget(streak: state.streak),
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