import 'package:ai_study_planner/features/auth/presentation/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/screen_pump.dart';

void main() {
  late ScreenHarness harness;

  setUp(() async {
    harness = ScreenHarness();
    await harness.init();
  });

  Future<void> pumpLogin(
    WidgetTester tester, {
    required double textScale,
  }) {
    return pumpScreen(
      tester,
      const LoginScreen(),
      overrides: harness.overrides(),
      textScale: textScale,
    );
  }

  testWidgets('skala teks 1.0: judul dan dua isian tampil', (tester) async {
    await pumpLogin(tester, textScale: 1.0);

    expect(find.text('Masuk'), findsAtLeastNWidgets(2));
    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Sandi'), findsOneWidget);
    expectNoOverflow(tester);
  });

  testWidgets('skala teks 2.0: tanpa overflow', (tester) async {
    await pumpLogin(tester, textScale: 2.0);

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Sandi'), findsOneWidget);
    expectNoOverflow(tester);
  });

  testWidgets('banner kedaluwarsa tampil dan email terakhir terisi',
      (tester) async {
    final now = harness.clock.fixedNow;
    await harness.sessionStore.catatLogin(
      email: 'bocil@kampus.ac.id',
      at: now,
    );

    await pumpScreen(
      tester,
      const LoginScreen(kedaluwarsa: true),
      overrides: harness.overrides(),
      textScale: 1.0,
    );

    expect(
      find.text(
        'Sesi kamu sudah berakhir. Silakan masuk lagi untuk melanjutkan.',
      ),
      findsOneWidget,
    );
    expect(find.text('bocil@kampus.ac.id'), findsOneWidget);
    expectNoOverflow(tester);
  });

  testWidgets('tanpa kedaluwarsa: banner tidak tampil', (tester) async {
    await harness.sessionStore.simpanEmailTerakhir('lama@kampus.ac.id');

    await pumpLogin(tester, textScale: 1.0);

    expect(
      find.byIcon(Icons.info_outline),
      findsNothing,
    );
    expect(find.text('lama@kampus.ac.id'), findsNothing);
  });
}
