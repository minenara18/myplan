import 'package:ai_study_planner/features/home/presentation/screen/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/screen_pump.dart';

void main() {
  late ScreenHarness harness;

  setUp(() async {
    harness = ScreenHarness();
    await harness.init();
  });

  Future<void> pumpHome(
    WidgetTester tester, {
    required double textScale,
  }) {
    return pumpScreen(
      tester,
      const HomeScreen(),
      overrides: harness.overrides(),
      textScale: textScale,
    );
  }

  testWidgets('skala teks 1.0: sapaan, fokus, aksi cepat tampil',
      (tester) async {
    await pumpHome(tester, textScale: 1.0);

    expect(find.text('Halo, Pengguna'), findsOneWidget);
    expect(find.text('Progres Hari Ini'), findsOneWidget);
    expect(find.text('Fokus Hari Ini'), findsOneWidget);
    expect(find.text('Aksi Cepat'), findsOneWidget);
    expect(find.byTooltip('Mulai Sesi'), findsOneWidget);
    expectNoOverflow(tester);
  });

  testWidgets('skala teks 2.0: tanpa overflow', (tester) async {
    await pumpHome(tester, textScale: 2.0);

    expect(find.text('Halo, Pengguna'), findsOneWidget);
    expectNoOverflow(tester);
  });
}
