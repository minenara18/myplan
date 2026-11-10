import 'package:ai_study_planner/features/splash/presentation/notifier/splash_notifier.dart';
import 'package:ai_study_planner/features/splash/presentation/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/screen_pump.dart';

void main() {
  late ScreenHarness harness;
  final rute = <String>[];

  List<Override> overridesDenganSplash() => [
        ...harness.overrides(),
        splashNotifierFactoryProvider.overrideWith((ref) {
          return (context) {
            return SplashNotifier(
              sessionStore: harness.sessionStore,
              onboardingService: harness.onboardingService,
              clock: harness.clock,
              keeper: harness.sessionKeeper,
              navigasi: rute.add,
              durasiMinimal: const Duration(milliseconds: 16),
              durasiMaksimal: const Duration(milliseconds: 100),
            );
          };
        }),
      ];

  setUp(() async {
    harness = ScreenHarness();
    await harness.init();
    rute.clear();
  });

  Widget bungkus({double textScale = 1.0, bool disableAnimations = false}) {
    return ProviderScope(
      overrides: overridesDenganSplash(),
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: disableAnimations,
          ),
          child: const SplashScreen(),
        ),
      ),
    );
  }

  testWidgets('skala teks 1.0: nama, ikon, indikator tampil', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(bungkus());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('MyPlan'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expectNoOverflow(tester);

    // Keadaan baru: tanpa onboarding, tanpa token.
    expect(rute, ['/onboarding']);
  });

  testWidgets('skala teks 2.0: tanpa overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(bungkus(textScale: 2.0));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('MyPlan'), findsOneWidget);
    expectNoOverflow(tester);
  });

  testWidgets('reduce motion: tampilan statis tanpa controller', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(bungkus(disableAnimations: true));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('MyPlan'), findsOneWidget);
    expectNoOverflow(tester);
    // Tanpa animasi tetap navigasi: keadaan baru -> /onboarding.
    expect(rute, ['/onboarding']);
  });
}
