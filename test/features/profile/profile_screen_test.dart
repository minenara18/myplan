import 'package:ai_study_planner/features/profile/presentation/screen/profile_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/screen_pump.dart';

void main() {
  late ScreenHarness harness;

  setUp(() async {
    harness = ScreenHarness();
    await harness.init();
  });

  Future<void> pumpProfile(
    WidgetTester tester, {
    required double textScale,
  }) {
    return pumpScreen(
      tester,
      const ProfileScreen(),
      overrides: harness.overrides(),
      textScale: textScale,
    );
  }

  testWidgets('skala teks 1.0: profil dan pengaturan tampil',
      (tester) async {
    await pumpProfile(tester, textScale: 1.0);

    expect(find.text('Pengguna'), findsOneWidget);
    expect(find.text('pengguna@example.com'), findsOneWidget);
    expect(find.text('Pengingat'), findsOneWidget);
    expect(find.text('Durasi Pomodoro Bawaan'), findsOneWidget);
    expect(find.text('Waktu Luang Harian'), findsOneWidget);
    expectNoOverflow(tester);
  });

  testWidgets('skala teks 2.0: tanpa overflow', (tester) async {
    await pumpProfile(tester, textScale: 2.0);

    expect(find.text('Pengguna'), findsOneWidget);
    expectNoOverflow(tester);
  });
}
