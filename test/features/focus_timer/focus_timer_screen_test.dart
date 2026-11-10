import 'package:ai_study_planner/features/focus_timer/presentation/screen/focus_timer_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/screen_pump.dart';

void main() {
  late ScreenHarness harness;

  setUp(() async {
    harness = ScreenHarness();
    await harness.init();
  });

  Future<void> pumpTimer(
    WidgetTester tester, {
    required double textScale,
  }) {
    return pumpScreen(
      tester,
      const FocusTimerScreen(),
      overrides: harness.overrides(),
      textScale: textScale,
    );
  }

  testWidgets('skala teks 1.0: judul, lingkaran, kontrol tampil',
      (tester) async {
    await pumpTimer(tester, textScale: 1.0);

    expect(find.text('Focus Timer'), findsOneWidget);
    expect(find.text('Siap'), findsOneWidget);
    expect(find.byTooltip('Mulai'), findsOneWidget);
    expect(find.byTooltip('Lewati sesi'), findsOneWidget);
    expect(find.byTooltip('Atur ulang'), findsOneWidget);
    expectNoOverflow(tester);
  });

  testWidgets('skala teks 2.0: pilihan durasi Wrap tanpa overflow',
      (tester) async {
    await pumpTimer(tester, textScale: 2.0);

    expect(find.text('Focus Timer'), findsOneWidget);
    expectNoOverflow(tester);
  });
}
