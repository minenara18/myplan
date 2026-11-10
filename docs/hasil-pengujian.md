# Hasil Pengujian

Semua angka di bawah disalin apa adanya dari hasil perintah, diukur pada
10 November 2026. Apa yang belum dikerjakan dinyatakan tegas "belum dijalankan".

## Ringkasan

| Pemeriksaan | Perintah | Hasil |
| --- | --- | --- |
| Analisis statis Flutter | `flutter analyze` | **No issues found!** (0 issue, ran in 26.7 s) |
| Test unit + widget Flutter | `flutter test` | **All tests passed!** — 108 test lulus (0 gagal) |
| Test backend | `cd backend && php artisan test` | **29 test lulus, 142 assertion** (57.95 s) |
| Integration test | `flutter test integration_test -d <device>` | **Belum dijalankan** — tidak ada emulator/perangkat terpasang |
| Migrasi PostgreSQL | `php artisan migrate` (db pengembangan) | **Belum dijalankan** — pengujian hanya di SQLite in-memory (lihat catatan di bawah) |
| APK release | `flutter build apk --release` | **app-release.apk 52.9 MB** (debug-signed) — 1220.6 s |

## Detail Flutter `flutter test` (108 test)

Pemisahan per kelompok:

| Kelompok | File | Jumlah | Hasil |
| --- | --- | --- | --- |
| Kontras WCAG | `test/contrast_test.dart` | 4 | lulus |
| Model core | `test/core/models/{course,focus_record,study_session,task}_test.dart` | 15 | lulus |
| Streak | `test/core/streak_test.dart` | 6 | lulus |
| Repository fake | `test/data/repositories/fake_*_test.dart` | 14 | lulus |
| Repository remote | `test/data/repositories/remote_course_repository_test.dart` | 9 | lulus |
| Notifier AI | `test/features/ai_planner/{ai_planner,ai_summary}_notifier_test.dart` | 8 | lulus |
| Notifier auth/calendar/tasks | `test/features/…/*_notifier_test.dart` | 18 | lulus |
| Widget test layar (2 skala teks per layar) | lihat tabel skenario | 20 | lulus |
| Widget test komponen | `test/features/tasks/tasks_widget_test.dart`, `test/theme_components_test.dart` | 4 | lulus |
| Redirect guard | `test/redirect_guard_test.dart` | 8 | lulus |
| Preferensi onboarding | `test/services/onboarding_preferences_service_test.dart` | 2 | lulus |
| **Total** | | **108** | **semua lulus** |

Widget test layar: setiap layar dites dua kali — skala teks 1.0 (isi tampil) dan
skala teks 2.0 (tidak ada RenderFlex overflow; tanpa `maxLines: 1`+ellipsis,
tanpa FittedBox untuk memaksa muat, tanpa menghilangkan assertion error).

## Tabel skenario utama (widget test layar)

Harness: `test/helpers/screen_pump.dart` — ukuran 390×844, jam tetap
9 November 2026 10.00 (`FakeClock`), semua repository fake dari
`ScreenHarness.init()`. Skala teks 2.0 disuntik lewat `MediaQuery.textScaler`.

| Skenario | Masukan | Diharapkan | Aktual | Status |
| --- | --- | --- | --- | --- |
| Onboarding — slide pertama | pump layar, skala 1.0 & 2.0 | judul slide + tombol "Lanjut" tampil, tanpa overflow | sesuai | PASS |
| Login — judul & dua kolom | pump layar, skala 1.0 & 2.0 | judul, kolom email & sandi, tombol masuk | sesuai | PASS |
| Beranda — sapaan & aksi cepat | pump + data fake, skala 1.0 & 2.0 | "Halo, Pengguna", "Progres Hari Ini", "Fokus Hari Ini", "Aksi Cepat", tooltip "Mulai Sesi" | sesuai | PASS |
| Tasks — daftar & filter | pump, skala 1.0 & 2.0 | judul, chip filter, isi daftar; skala 2.0 masih menggulir tanpa overflow | sesuai | PASS |
| Tasks — komponen kartu | TaskItemWidget | judul + prioritas tampil; checkbox menyala saat ditekan | sesuai | PASS |
| Calendar — strip sesi | pump, skala 1.0 & 2.0 | judul sesi "Sesi Belajar", tooltip "Tambah Sesi"; chip minggu + kartu tidak overflow (skala 2.0 chip dan kartu juga tidak jadi overflow) | sesuai | PASS |
| AI planner — masukan awal | pump, skala 1.0 & 2.0 | "Rencana Belajar", "Susun slot belajar otomatis", "Waktu luang 16.00 – 21.00 setiap hari", Semantics "Rekam suara (segera hadir)" | sesuai | PASS |
| Ringkas materi — isian | pump, skala 1.0 & 2.0 | isian teks aktif + tombol Ringkas tampil | sesuai | PASS |
| Focus timer — judul & kontrol | pump, skala 1.0 & 2.0 | "Focus Timer", "Siap", tooltip Mulai/Lewati/Atur ulang; skala 2.0: pilihan durasi Wrap tanpa overflow (lingkaran ikut membesar) | sesuai | PASS |
| Progress — judul & chart | pump + scroll, skala 1.0 & 2.0 | judul, kartu statistik, chart; tanpa overflow saat digulir | sesuai | PASS |
| Profil — pengaturan | pump, skala 1.0 & 2.0 | avatar, bagian Pengaturan, item pengaturan; skala 2.0 tanpa overflow | sesuai | PASS |
| Redirect guard | 8 kombinasi status login/onboarding | arah redirect sesuai tabel di `test/redirect_guard_test.dart` | sesuai | PASS |

Test backend (`php artisan test` — SQLite in-memory via `.env.testing`):
29 test / 142 assertion mencakup auth Sanctum (register/login/logout),
CRUD courses, tasks, sessions (termasuk `sessions/bulk`), focus-records,
stats weekly, settings, dan AI endpoints (fallback deterministik).

## Catatan database: SQLite vs PostgreSQL

- `backend/.env.testing` memakai `DB_CONNECTION=sqlite` + `DB_DATABASE=:memory:`
  → seluruh 29 test backend berjalan di **SQLite**.
- `backend/.env` pengembangan memakai `DB_CONNECTION=pgsql`, tetapi
  **migrasi/pengujian PostgreSQL belum dijalankan** di lingkungan kerja ini
  (panduan pemasangan ada di `docs/setup-postgres.md`). Kolom `jsonb`
  (`users.settings`) dipetakan Laravel ke tipe JSON saat di SQLite —
  perlu diuji ulang di PostgreSQL saat migrasi dilakukan.

## Yang masih perlu dijalankan di tempat lain (tidak dijalankan sekarang)

1. `flutter test integration_test -d <device>` — alur
   login(fake) → tambah tugas → susun AI → terapkan → kalender
   (`integration_test/alur_rencana_ai_test.dart`, file sudah lengkap).
2. Migrasi + uji PostgreSQL (`php artisan migrate --env=development` dengan
   `DB_CONNECTION=pgsql`).
3. Uji manual Part B (`docs/uji-manual.md`): jank profile mode, sapuan visual
   skala teks + reduce motion, alur sesi/jam fake.
4. Jadwal Fase E sesi 60 hari & splash (sudah direncanakan di `docs/sesi.md`).

## APK release

- Perintah: `flutter build apk --release`
- Hasil: **√ Built build\app\outputs\flutter-apk\app-release.apk (52.9 MB)**
  (Gradle task `assembleRelease` 1220.6 s).
- Di-sign debug (keystore release belum disiapkan) — cukup untuk demo; untuk
  toko play dibuat keystore sendiri.
- Ukuran besar karena APK fat berisi lib engine untuk armeabi-v7a, arm64-v8a,
  dan x86_64 sekaligus; per perangkat, APK split per ABI (-flag `--split-per-abi`)
  atau app bundle `flutter build appbundle` bisa dipakai bila dibutuhkan.

