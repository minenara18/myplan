import 'package:ai_study_planner/features/onboarding/presentation/screen/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/screen_pump.dart';

void main() {
  late ScreenHarness harness;

  setUp(() async {
    harness = ScreenHarness();
    await harness.init();
  });

  Future<void> pumpOnboarding(
    WidgetTester tester, {
    required double textScale,
  }) {
    return pumpScreen(
      tester,
      OnboardingScreen(onSelesai: () {}),
      overrides: harness.overrides(),
      textScale: textScale,
    );
  }

  testWidgets('skala teks 1.0: slide pertama dan tombol lanjut tampil',
      (tester) async {
    await pumpOnboarding(tester, textScale: 1.0);

    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);
    expectNoOverflow(tester);
  });

  testWidgets('skala teks 2.0: tanpa overflow', (tester) async {
    await pumpOnboarding(tester, textScale: 2.0);

    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);
    expectNoOverflow(tester);
  });
}
