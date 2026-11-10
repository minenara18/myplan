# ChangeLog

Proyek MyPlan (AI Study Planner). Riwayat di bawah disusun per minggu dari
`git log` (7 commit pertama, 27 Oktober – 1 November 2026).

> **Catatan penting:** file `docs/catatan-mingguan.md` **tidak ada** di
> repositori — catatan mingguan belum pernah dibuat sebelumnya. Dokumen ini
> disusun dari log commit agar laporan tetap punya riwayat. Jika kamu punya
> jurnal pribadi per minggu, lengkapi bagian pada dokumen ini secara manual.

## Minggu 1 (27 Oktober 2026)

| Tanggal | Commit | Ringkasan |
| --- | --- | --- |
| 2026-10-27 | `ea6863d` | chore: tambah AGENTS.md dan acuan desain |

- Fondasi peraturan proyek (AGENTS.md) dan acuan visual di `docs/design/`
  (palet Moonstone/Vanilla, glassmorphism halus, DM Serif Display + Inter).

## Minggu 2 (31 Oktober – 1 November 2026)

| Tanggal | Commit | Ringkasan |
| --- | --- | --- |
| 2026-10-31 | `8aa4e46` | chore: gitignore dan fondasi proyek Flutter |
| 2026-10-31 | `86158ff` | feat: data repository dan fitur Flutter inti (auth, onboarding, beranda, kalender, fokus, tugas, progres, profil) |
| 2026-10-31 | `dfc43a4` | feat(backend): API Laravel — auth Sanctum, tugas, mata kuliah, sesi belajar, fokus, statistik, pengaturan |
| 2026-10-31 | `f04e010` | feat(ai): perencana AI dan ringkas materi — endpoint `/api/ai/plan`, `/api/ai/summarize`, provider, fitur Flutter ai_planner; spesifikasi OpenAPI dan Postman |
| 2026-11-01 | `e9f4bc2` | feat(platform): folder android/ios (org com.jasmine, application id com.jasmine.myplan), label MyPlan, izin INTERNET, cleartext hanya debug/profile, splash natife #FFFFFF dan ikon launcher dari logo placeholder |
| 2026-11-01 | `718d4db` | chore: hapus l10n.yaml vestigial yang memicu kegagalan gen_localizations saat build apk; catatan penggantian logo placeholder di docs/sesi.md |

Rincian:

- **Fondasi aplikasi**: struktur feature-first, Riverpod, GoRouter,
  theme/token di `lib/theme/`, sistem l10n dictionary hand-written (kodegen
  `flutter gen-l10n` tidak dipakai — lihat `docs/sesi.md`).
- **Fitur inti**: auth + onboarding, beranda, kalender (dan tambah sesi manual),
  focus timer, tugas, progres, profil — semuanya dengan repository fake/remote
  yang dipilih lewat `USE_FAKE`.
- **Backend**: Laravel 12 dengan auth Sanctum, resource courses, tasks,
  study_sessions, focus_records, stats weekly, settings; pengujian PHPUnit.
- **AI**: endpoint `/api/ai/plan` dan `/api/ai/summarize` (provider kompatibel
  OpenAI + perencana deterministik sebagai fallback), fitur `ai_planner`
  (perencana + ringkas materi), `docs/openapi.yaml`, koleksi Postman.
- **Platform**: Android/iOS disiapkan (label MyPlan, izin INTERNET, cleartext
  hanya debug/profile), splash natif putih, dan ikon launcher dari logo
  placeholder (logo asli belum ada — lihat `docs/sesi.md`).

## Minggu 3 (9–10 November 2026) — sapuan kualitas (belum di-commit)

Pekerjaan berikut berada di working tree dan **belum di-commit** pada saat
dokumen ini ditulis:

- Widget tests seluruh layar utama (skala teks 1.0 & 2.0), `test/helpers/`
  (harness `ScreenHarness` + fake auth untuk integration test), 108 test
  lulus; `flutter analyze` bersih; integration test `alur_rencana_ai_test`
  sudah ditulis (belum dijalankan — tidak ada emulator).
- Perbaikan aksesibilitas & bug dari sapuan: watch penuh di tasks/calendar/
  focus timer (bukan `provider.notifier`), tanpa `BackdropFilter` di item
  daftar, sheet tambah sesi disambung ke data (chip durasi + showTimePicker),
  teks membungkus tanpa ellipsis, tooltips/Semantics, token warna, waktu lewat
  `Clock` yang disuntik.
- Bahasa Indonesia tunggal di seluruh UI (dictionary `lib/l10n/`).
- Dokumen: README.md, docs/arsitektur.md, docs/endpoint.md,
  docs/hasil-pengujian.md, docs/uji-manual.md, docs/screenshot-bab4.md,
  CHANGELOG.md (file ini).
