import 'package:ai_study_planner/features/progress/presentation/screen/progress_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/screen_pump.dart';

void main() {
  late ScreenHarness harness;

  setUp(() async {
    harness = ScreenHarness();
    await harness.init();
  });

  Future<void> pumpProgress(
    WidgetTester tester, {
    required double textScale,
  }) {
    return pumpScreen(
      tester,
      const ProgressScreen(),
      overrides: harness.overrides(),
      textScale: textScale,
    );
  }

  testWidgets('skala teks 1.0: judul, kartu statistik, chart tampil',
      (tester) async {
    await pumpProgress(tester, textScale: 1.0);

    expect(find.text('Progress Belajar'), findsOneWidget);
    expect(find.text('Jam Belajar'), findsOneWidget);
    expect(find.text('Tugas Selesai'), findsOneWidget);
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('Aktivitas Minggu Ini'), findsOneWidget);
    expectNoOverflow(tester);
  });

  testWidgets('skala teks 2.0: tanpa overflow saat digulir', (tester) async {
    await pumpProgress(tester, textScale: 2.0);

    expect(find.text('Progress Belajar'), findsOneWidget);
    expectNoOverflow(tester);

    // Gulir ke bagian chart donut.
    await tester.fling(
        find.text('Progress Belajar'), const Offset(0, -400), 1000);
    await tester.pump(const Duration(milliseconds: 400));
    expectNoOverflow(tester);
  });
}
