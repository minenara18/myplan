# MyPlan — AI Study Planner

Aplikasi mobile perencana belajar mahasiswa (berbahasa Indonesia). Mahasiswa
mencatat mata kuliah dan tugas, lalu menyusun jadwal belajar mingguan dengan
bantuan AI — baik dari slot waktu luang harian maupun ringkasan materi paket
mata kuliah.

Proyek magang, dua bagian:

| Bagian | Isi |
| --- | --- |
| **`lib/` (root)** | Aplikasi Flutter: Riverpod 3, GoRouter, Dio, fl_chart. |
| **`backend/`** | API Laravel 12 + Sanctum + PostgreSQL. AI dipanggil dari sini; kunci API tidak pernah ada di aplikasi. |

## Stack

- Flutter (Dart 3), Riverpod 3 (Notifier/AsyncNotifier), GoRouter, Dio, fl_chart
- Backend: Laravel 12, Sanctum, PostgreSQL (pengujian memakai SQLite in-memory)
- LLM: endpoint kompatibel OpenAI (`backend/config/ai.php`), dengan fallback
  perencana deterministik (`App\Services\Ai\DeterministicPlanner`) jika LLM gagal

## Menjalankan aplikasi (mode demo, tanpa backend)

Mode bawaan memakai data fake in-memory — cocok untuk demo tanpa server:

```powershell
flutter pub get
flutter run
```

Jalankan di perangkat/emulator; splash natif #FFFFFF dan ikon launcher sudah
dikonfigurasi (logo saat ini masih placeholder, lihat `docs/sesi.md`).

## Menjalankan aplikasi dengan backend

```powershell
flutter run --dart-define=USE_FAKE=false --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

- `API_BASE_URL` default `http://10.0.2.2:8000/api` (emulator Android → localhost
  host). Perangkat fisik: ganti ke IP LAN laptop, mis. `http://192.168.1.10:8000/api`.
- Build release tidak mengizinkan cleartext HTTP — gunakan HTTPS untuk backend
  produksi. Rinciannya di `docs/sesi.md`.

## Menjalankan backend

```powershell
cd backend
composer install
cp .env.example .env   # lalu isi DB_*, AI_*
php artisan migrate
php artisan serve      # http://127.0.0.1:8000 — dari emulator memakai 10.0.2.2
```

Variabel penting di `backend/.env`:

| Variabel | Keterangan |
| --- | --- |
| `DB_CONNECTION` / `DB_DATABASE` | Database utama. Pengembangan memakai `pgsql`; `docs/setup-postgres.md` berisi panduan instalasinya. |
| `AI_API_KEY`, `AI_BASE_URL`, `AI_MODEL`, `AI_TIMEOUT` | Kunci API LLM (disimpan hanya di `.env`, tidak pernah dibundel ke aplikasi). Kompatibel OpenAI: cukup ganti `AI_BASE_URL` + `AI_MODEL` untuk pindah penyedia. |

## Pengujian

```powershell
# Flutter: analisis statis + unit/widget test
flutter analyze
flutter test

# Backend: PHPUnit/Pest (SQLite in-memory, lihat whitelist hasil)
cd backend; php artisan test

# Integration test (perlu emulator/perangkat aktif)
flutter test integration_test -d <device>
```

Angka hasil terakhir (rinci per kasus di `docs/hasil-pengujian.md`):

| Pemeriksaan | Hasil terakhir |
| --- | --- |
| `flutter analyze` | No issues found! (0 issue) |
| `flutter test` (unit + widget) | 108 test lulus |
| `flutter test integration_test` | **Belum dijalankan** — tidak ada emulator/perangkat |
| `php artisan test` (SQLite in-memory) | 29 test lulus, 142 assertion |
| Uji database PostgreSQL | Migrasi PostgreSQL belum dijalankan — pengujian hanya di SQLite |
| `flutter build apk --release` | app-release.apk 52.9 MB (debug-signed) |

## Struktur

```
lib/
  main.dart              # tipis, memanggil bootstrap
  bootstrap.dart         # pilih Fake/Remote repository lewat USE_FAKE
  app.dart               # MaterialApp + GoRouter
  core/                  # model murni, Result/Failure, Clock
  data/                  # ApiClient (Dio), repository fake & remote, observer
  services/              # preferensi (SharedPreferences), token storage
  routing/               # route, guard redirect (login/onboarding)
  theme/                 # token warna/typography + komponen kaca (components/)
  l10n/                  # dictionary teks Indonesia (hand-written) + app_id.arb
  features/
    onboarding/ auth/ home/ tasks/ calendar/ ai_planner/ focus_timer/
    progress/ profile/
backend/
  app/Http/Controllers/Api/   # controller per resource
  app/Services/Ai/            # AiPlanner, MateriSummarizer, DeterministicPlanner,
                              # OpenAiCompatibleProvider, PlanValidator
  database/migrations/        # users(+settings), courses, tasks, study_sessions,
                              # focus_records, ai_plans, personal_access_tokens
  routes/api.php              # semua endpoint (lihat docs/endpoint.md)
  docs/openapi.yaml           # spesifikasi OpenAPI lengkap
docs/
  arsitektur.md  endpoint.md  hasil-pengujian.md  uji-manual.md
  screenshot-bab4.md  setup-postgres.md  sesi.md  openapi.yaml
  postman/
```

## Konvensi kode

- View menampilkan state dari satu Notifier per fitur; aksi lewat method Notifier.
- Repository satu-satunya jalur baca/tulis data; kegagalan jaringan menjadi nilai
  (`sealed Failure`) dan tampil lewat `AsyncValue` — tidak ada catch kosong.
- Waktu lewat `Clock` yang disuntik, bukan `DateTime.now()` langsung di fitur.
- Tidak ada warna/radius/durasi/ukuran font mentah di luar `lib/theme/`.
- Semua teks UI lewat `l10n('Key')` (`lib/l10n/`), bukan literal di widget.
- Aksesibilitas: ikon tanpa teks wajib punya `Semantics`/tooltip, target sentuh
  minimal 48px, warna tidak jadi satu-satunya penanda status, seluruh layar
  diuji pada skala teks 1.0 dan 2.0 tanpa overflow.

## Catatan

- **Splash & sesi 60 hari belum diimplementasikan** — rencananya bagian Fase E,
  lihat `docs/sesi.md`. Ikon/splash natif sudah disiapkan, kode Flutter-nya belum.
- Riwayat mingguan kerja ada di `CHANGELOG.md`; `docs/catatan-mingguan.md`
  tidak ada (belum pernah dibuat) — lihat catatan di CHANGELOG.md.
