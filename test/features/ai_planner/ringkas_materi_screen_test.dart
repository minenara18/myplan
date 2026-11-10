import 'package:ai_study_planner/features/ai_planner/presentation/screen/ringkas_materi_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/screen_pump.dart';

void main() {
  late ScreenHarness harness;

  setUp(() async {
    harness = ScreenHarness();
    await harness.init();
  });

  Future<void> pumpRingkas(
    WidgetTester tester, {
    required double textScale,
  }) {
    return pumpScreen(
      tester,
      const RingkasMateriScreen(),
      overrides: harness.overrides(),
      textScale: textScale,
    );
  }

  testWidgets('skala teks 1.0: isian teks dan tombol ringkas tampil',
      (tester) async {
    await pumpRingkas(tester, textScale: 1.0);

    expect(find.text('Ringkas Materi'), findsOneWidget);
    expect(find.text('Tempel teks kuliah di sini'), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    expectNoOverflow(tester);
  });

  testWidgets('skala teks 2.0: tanpa overflow', (tester) async {
    await pumpRingkas(tester, textScale: 2.0);

    expect(find.text('Tempel teks kuliah di sini'), findsOneWidget);
    expectNoOverflow(tester);
  });
}
