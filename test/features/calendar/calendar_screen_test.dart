import 'package:ai_study_planner/features/calendar/presentation/screen/calendar_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/screen_pump.dart';

void main() {
  late ScreenHarness harness;

  setUp(() async {
    harness = ScreenHarness();
    await harness.init();
  });

  Future<void> pumpCalendar(
    WidgetTester tester, {
    required double textScale,
  }) {
    return pumpScreen(
      tester,
      const CalendarScreen(),
      overrides: harness.overrides(),
      textScale: textScale,
    );
  }

  testWidgets('skala teks 1.0: strip minggu dan kartu sesi tampil',
      (tester) async {
    await pumpCalendar(tester, textScale: 1.0);

    // FakeSessionRepository punya sesi 2 jam sebelum jam tetap (10.00),
    // yaitu hari yang sama (9 Nov 2026) -> kartu tampil.
    expect(find.text('Sesi Belajar'), findsOneWidget);
    expect(find.byTooltip('Tambah Sesi'), findsOneWidget);
    expectNoOverflow(tester);
  });

  testWidgets('skala teks 2.0: strip minggu dan kartu tanpa overflow',
      (tester) async {
    await pumpCalendar(tester, textScale: 2.0);

    expect(find.text('Sesi Belajar'), findsOneWidget);
    expectNoOverflow(tester);
  });
}
