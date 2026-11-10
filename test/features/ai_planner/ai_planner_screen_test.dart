import 'package:ai_study_planner/features/ai_planner/presentation/screen/ai_planner_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/screen_pump.dart';

void main() {
  late ScreenHarness harness;

  setUp(() async {
    harness = ScreenHarness();
    await harness.init();
  });

  Future<void> pumpAiPlanner(
    WidgetTester tester, {
    required double textScale,
  }) {
    return pumpScreen(
      tester,
      const AiPlannerScreen(),
      overrides: harness.overrides(),
      textScale: textScale,
    );
  }

  testWidgets('skala teks 1.0: masukan awal dan tombol susun tampil',
      (tester) async {
    await pumpAiPlanner(tester, textScale: 1.0);

    expect(find.text('Rencana Belajar'), findsOneWidget);
    expect(find.text('Susun slot belajar otomatis'), findsOneWidget);
    expect(find.text('Waktu luang 16.00 – 21.00 setiap hari'),
        findsOneWidget);
    expect(
        find.bySemanticsLabel('Rekam suara (segera hadir)'), findsOneWidget);
    expectNoOverflow(tester);
  });

  testWidgets('skala teks 2.0: tanpa overflow', (tester) async {
    await pumpAiPlanner(tester, textScale: 2.0);

    expect(find.text('Rencana Belajar'), findsOneWidget);
    expectNoOverflow(tester);
  });
}
