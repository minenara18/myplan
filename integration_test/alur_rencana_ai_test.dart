import 'package:ai_study_planner/app.dart';
import 'package:ai_study_planner/data/repositories/auth_repository.dart';
import 'package:ai_study_planner/services/onboarding_preferences_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/helpers/screen_pump.dart';
import '../test/helpers/test_auth_repository.dart';
import 'package:flutter/material.dart';

/// Alur integrasi (B4):
/// login (fake) -> onboarding selesai -> tambah tugas -> susun jadwal AI
/// -> terapkan -> jadwal terlihat di kalender.
///
/// CATATAN UNTUK SAPUAN INI: test ini BELUM DIJALANKAN karena tidak ada
/// emulator/perangkat yang tersedia. Jalankan dengan:
///   flutter test integration_test -d <emulator atau perangkat>
/// Semua repository memakai fake (mode demo) sehingga tidak butuh backend.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'alur: login -> onboarding -> tambah tugas -> AI terapkan -> kalender',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final harness = ScreenHarness();
      await harness.init();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...harness.overrides(),
            authRepositoryProvider.overrideWithValue(
              FakeAuthRepositoryForTest(
                onboardingService: SharedPreferencesOnboardingService(prefs),
              ),
            ),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // 1) LOGIN (fake)
      final kolomEmail = find.byType(TextField).first;
      final kolomSandi = find.byType(TextField).last;
      await tester.enterText(kolomEmail, 'pengguna@example.com');
      await tester.enterText(kolomSandi, 'rahasia123');
      await tester.tap(find.text('Masuk').last);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // 2) ONBOARDING selesai -> beranda
      await tester.tap(find.text('Lanjut')); // ke slide 2
      await tester.pump();
      await tester.tap(find.text('Lanjut')); // ke slide 3
      await tester.pump();
      await tester.tap(find.text('Mulai')); // selesai
      await tester.pumpAndSettle();
      expect(find.text('Halo, Pengguna'), findsOneWidget);

      // 3) TAMBAH TUGAS
      await tester.tap(find.byTooltip('Tambah Tugas'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Tugas Uji');
      // Mudah hilang fokus pilihan mata kuliah/tenggat: pakai tombol Tambah
      // bila map dipilih penuh; test ini hanya cek penerapan alur dasar.
      await tester.tap(find.text('Tambah'));
      await tester.pumpAndSettle();
      expect(find.text('Tugas Uji'), findsOneWidget);

      // 4) SUSUN JADWAL AI lewat tab AI di bar bawah
      await tester.tap(find.bySemanticsLabel('AI'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Susun slot belajar otomatis'));
      await tester.pump(const Duration(seconds: 2)); // fake repo delay 600 ms
      await tester.pumpAndSettle();
      expect(find.text('Terapkan ke Kalender'), findsOneWidget);

      // 5) TERAPKAN -> snackbar + pindah ke tab kalender
      await tester.tap(find.text('Terapkan ke Kalender'));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Tambah Sesi'), findsOneWidget);
      expect(find.text('Sesi Belajar'), findsOneWidget);
    },
  );
}
