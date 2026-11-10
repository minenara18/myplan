import 'package:ai_study_planner/features/tasks/presentation/screen/tasks_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/screen_pump.dart';

void main() {
  late ScreenHarness harness;

  setUp(() async {
    harness = ScreenHarness();
    await harness.init();
  });

  Future<void> pumpTasks(
    WidgetTester tester, {
    required double textScale,
  }) {
    return pumpScreen(
      tester,
      const TasksScreen(),
      overrides: harness.overrides(),
      textScale: textScale,
    );
  }

  testWidgets('skala teks 1.0: judul, filter, dan isi daftar tampil',
      (tester) async {
    await pumpTasks(tester, textScale: 1.0);

    expect(find.text('Tugas'), findsOneWidget);
    expect(find.byTooltip('Tambah Tugas'), findsOneWidget);
    // Isi dari FakeTaskRepository default.
    expect(find.text('Tugas Flutter UI'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expectNoOverflow(tester);
  });

  testWidgets('skala teks 2.0: daftar bisa digulir tanpa overflow',
      (tester) async {
    await pumpTasks(tester, textScale: 2.0);

    expect(find.text('Tugas Flutter UI'), findsOneWidget);
    expectNoOverflow(tester);

    // Gulir hingga akhir: judul terakhir terlihat tanpa overflow.
    await tester.fling(find.text('Tugas Flutter UI'), const Offset(0, -300),
        1000);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Tugas Chatbot'), findsOneWidget);
    expectNoOverflow(tester);
  });
}
