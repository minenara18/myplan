import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/theme/components/ambient_background.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';
import 'package:ai_study_planner/features/onboarding/presentation/notifier/onboarding_notifier.dart';
import 'package:ai_study_planner/features/onboarding/presentation/widgets/onboarding_slide.dart';

/// Layar onboarding dengan 3 slide, indikator titik, dan tombol lanjut.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    final slides = [
      OnboardingSlide(
        title: 'Selamat Datang',
        description:
            'Rencanakan jadwal belajarmu dengan mudah dan terstruktur.',
        icon: Icons.calendar_today,
        color: ColorTokens.moonstone,
      ),
      OnboardingSlide(
        title: 'AI Study Planner',
        description:
            'Dapatkan rekomendasi waktu belajar yang disesuaikan kebutuhanmu.',
        icon: Icons.smart_toy,
        color: ColorTokens.moonstoneTint,
      ),
      OnboardingSlide(
        title: 'Mulai Belajar',
        description:
            'Siapkan rencana belajarmu dan raih prestasi akademik yang lebih baik.',
        icon: Icons.play_arrow,
        color: ColorTokens.vanilla,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(circleCount: 3),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    itemCount: slides.length,
                    onPageChanged: notifier.setPage,
                    itemBuilder: (context, index) => slides[index],
                  ),
                ),
                // Indikator titik
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(slides.length, (index) {
                    return Container(
                      width: state.currentPage == index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: state.currentPage == index
                            ? ColorTokens.moonstone
                            : ColorTokens.moonstone.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                // Tombol lanjut
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (state.currentPage == slides.length - 1) {
                          // TODO: simpan ke preferences dan arahkan ke auth/home
                        } else {
                          notifier.nextPage(slides.length);
                        }
                      },
                      icon: Icon(
                        state.currentPage == slides.length - 1
                            ? Icons.check
                            : Icons.navigate_next,
                        size: 20,
                      ),
                      label: Text(
                        state.currentPage == slides.length - 1
                            ? 'Mulai'
                            : 'Lanjut',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}