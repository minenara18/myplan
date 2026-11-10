# ChangeLog

Proyek MyPlan (AI Study Planner). Riwayat di bawah disusun per minggu dari
`git log` (27 Oktober – 10 November 2026).

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
| 2026-11-01 | `e9f4bc2` | feat(platform): folder android/ios (org com.jasmine, application id com.jasmine.myplan), label MyPlan, izin INTERNET, cleartext hanya debug/profile, splash natif #FFFFFF dan ikon launcher dari logo placeholder |
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

## Minggu 3 (9–10 November 2026) — sapuan kualitas

| Tanggal | Commit | Ringkasan |
| --- | --- | --- |
| 2026-11-10 | `7a98e49` | refactor(core,data): sapuan kualitas model dan repository — Clock disuntik, l10n, pengetatan tipe |
| 2026-11-10 | `28df824` | refactor(theme): token warna baru; GlassCard varian standard tanpa BackdropFilter untuk item daftar |
| 2026-11-10 | `6f6910c` | feat(l10n): puluhan kunci terjemahan Indonesia baru untuk seluruh layar |
| 2026-11-10 | `cf531d7` | refactor(routing): screen di lib/routing/screens dihapus — semua screen tinggal di features |
| 2026-11-10 | `591d277` | fix(features): sapuan aksesibilitas dan kebenaran UI seluruh layar |
| 2026-11-10 | `cf43d31` | chore(deps): integration_test (SDK Flutter) sebagai dev dependency |
| 2026-11-10 | `87d60b4` | test: widget test seluruh layar utama pada skala teks 1.0 dan 2.0 + harness ScreenHarness |
| 2026-11-10 | `30314fe` | test(integration): alur rencana AI — akan dijalankan saat ada emulator/perangkat |
| 2026-11-10 | `52991fd` | docs: README, arsitektur (Mermaid), tabel endpoint, hasil-pengujian, uji-manual (Bagian B), screenshot-bab4, CHANGELOG |

Rincian:

- Widget tests seluruh layar utama (skala teks 1.0 & 2.0), `test/helpers/`
  (harness `ScreenHarness` + fake auth untuk integration test);
  `flutter analyze` bersih; integration test `alur_rencana_ai_test`
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

## Minggu 4 (10 November 2026) — Fase E: sesi 60 hari & splash

| Tanggal | Commit | Ringkasan |
| --- | --- | --- |
| 2026-11-10 | `a435cde` | feat(core,services): kebijakan sesi 60 hari (SessionPolicy, sealed SessionDecision) dan SessionStore |
| 2026-11-10 | `423dc8f` | refactor(routing): rute /splash, SessionKeeper, guard berbasis keputusan sesi |
| 2026-11-10 | `1d17c6b` | feat(splash): SplashScreen kaca + SplashNotifier offline-first (1200–4000 ms) |
| 2026-11-10 | `6e896f5` | feat(auth): login menyambungkan alur sesi 60 hari (banner kedaluwarsa + prefill email) |
| 2026-11-10 | `2596de6` | chore(l10n): kunci SesiKedaluwarsa untuk banner login |
| 2026-11-10 | `98a9469` | test: policy, store, keeper/guard, splash, banner login |
| 2026-11-10 | `823bb53` | feat(backend): sesi 60 hari Sanctum — createToken expires_at 60 hari, RenewSessionToken (throttle Cache), 401 session_expired |
| 2026-11-10 | `83521e0` | test(backend): SessionExpiryTest — kedaluwarsa 61 hari, perpanjangan, throttle tulis, token tak dikenal |
| 2026-11-10 | `3f1254d` | docs(api): masa berlaku token 60 hari dan respons 401 session_expired (OpenAPI + Postman) |
| 2026-11-10 | `44df9e2` | fix(api): milah 401 — kedaluwarsa hanya untuk code session_expired; 401 login/register tidak menggugurkan sesi |
| 2026-11-10 | `d2b4850` | chore(backend): jadwal harian sanctum:prune-expired --hours=24 dan catatan driver Cache |

- Flutter: `SessionPolicy.maxIdle` 60 hari (Dart murni, jam mundur aman),
  `SessionStore` (token + lastActiveAt + email, touch throttle 1 jam,
  hapusSesi menjaga email), splash offline-first, guard/redirect berbasis
  keputusan sesi, login dengan banner kedaluwarsa.
- Backend: token berlaku 60 hari, tiap request terautentikasi memperpanjang
  (`RenewSessionToken`, throttle tulis 60 menit via Cache), 401
  `session_expired` dipisah dari 401 biasa, jadwal harian prune token
  kedaluwarsa.
- Hasil verifikasi: `flutter analyze` 0 issue, `flutter test` 156 test lulus,
  `php artisan test` (backend) 36 test / 166 assertion.
