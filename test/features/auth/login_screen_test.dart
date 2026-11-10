import 'package:ai_study_planner/features/auth/presentation/screen/login_screen.dart';
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
}
