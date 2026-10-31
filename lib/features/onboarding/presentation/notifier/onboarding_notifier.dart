import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State layar onboarding.
final class OnboardingState {
  const OnboardingState({this.currentPage = 0});

  final int currentPage;

  OnboardingState copyWith({int? currentPage}) {
    return OnboardingState(currentPage: currentPage ?? this.currentPage);
  }
}

/// Notifier untuk mengelola state onboarding.
class OnboardingNotifier extends Notifier<OnboardingState> {
  OnboardingNotifier();

  @override
  OnboardingState build() => const OnboardingState();

  /// Pindah ke slide berikutnya, kembali ke 0 jika sudah di slide terakhir.
  void nextPage(int totalPages) {
    state = state.copyWith(
      currentPage: (state.currentPage + 1) % totalPages,
    );
  }

  /// Tandai halaman tertentu sebagai aktif.
  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }
}

/// Provider onboarding notifier.
final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(OnboardingNotifier.new);