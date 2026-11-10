import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/core/session_policy.dart';
import 'package:ai_study_planner/core/system_clock.dart';
import 'package:ai_study_planner/routing/session_keeper.dart';
import 'package:ai_study_planner/services/session_store.dart';
import 'package:ai_study_planner/theme/app_theme.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';
import 'package:ai_study_planner/theme/components/ambient_background.dart';
import 'package:ai_study_planner/theme/components/glass_card.dart';
import 'package:ai_study_planner/features/splash/presentation/notifier/splash_notifier.dart';

/// Layar splash latar putih: kartu logo kaca, nama MyPlan serif, dan
/// indikator tipis Moonstone. Keputusan sesi dihitung lokal sehingga
/// offline tetap tahu mau ke mana.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(_mulai()),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  /// Kembali dari background: perpanjang sesi bila masih terautentikasi.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final keeperDecision = ref.read(sessionKeeperProvider).decision;
    if (keeperDecision is! Authenticated) return;
    unawaited(
      ref.read(sessionStoreProvider).touch(ref.read(clockProvider).now()),
    );
  }

  /// Fade+scale; reduce motion -> tampilan statis (animasi penuh seketika).
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null && !MediaQuery.disableAnimationsOf(context)) {
      final controller = AnimationController(
        vsync: this,
        duration: AppTheme.splashAnimDur,
      );
      _controller = controller;
      controller.forward();
    }
  }

  Future<void> _mulai() async {
    final notifier = ref.read(splashNotifierFactoryProvider)(context);
    await notifier.mulai();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AmbientBackground(circleCount: 2)),
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: GlassCard(
                variant: GlassCardVariant.hero,
                padding: const EdgeInsets.all(AppTheme.spacing32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_stories_rounded,
                      size: 48,
                      color: ColorTokens.moonstone,
                      semanticLabel: 'Logo MyPlan',
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    Text(
                      'MyPlan',
                      style: TextStyle(
                        fontFamily: AppTheme.dmSerifDisplay,
                        fontSize: 32,
                        color: ColorTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing24),
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ColorTokens.moonstone,
                        semanticsLabel: 'Memuat',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  /// Fade dan scale memakai controller yang sama; tanpa controller
  /// (reduce motion) keduanya bernilai akhir sehingga tampilan statis.
  Animation<double> get _fade => _controller ?? kAlwaysCompleteAnimation;

  Animation<double> get _scale => Tween<double>(begin: 0.96, end: 1).animate(
        _fade,
      );
}
