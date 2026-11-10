# Catatan sesi 60 hari & splash (Fase E — sudah dikerjakan)

Dokumen ini mencatat persiapan infrastruktur, lalu catatan implementasi Fase E:
sliding session 60 hari, splash Flutter, dan pengetatan Sanctum `expires_at`
yang semuanya sudah ada di kode dan test. Bagian akhir berisi sisa pekerjaan.

## Status persiapan folder platform

- Folder `android/` dan `ios/` dibuat dengan
  `flutter create . --platforms=android,ios --project-name ai_study_planner --org com.jasmine`.
  `lib/` dan `pubspec.yaml` tidak tersentuh flutter create (terverifikasi lewat git).
- Application id Android: `com.jasmine.myplan` (di `android/app/build.gradle.kts`),
  bundle id iOS: `com.jasmine.myplan` (di `ios/Runner.xcodeproj/project.pbxproj`,
  termasuk target `RunnerTests`).
- Label tampilan: Android `android:label="MyPlan"` di
  `android/app/src/main/AndroidManifest.xml`; iOS `CFBundleDisplayName` = `MyPlan`
  di `ios/Runner/Info.plist`.
- Izin `INTERNET` ditambahkan di AndroidManifest utama (build release
  memang tidak membawanya secara bawaan).
- Cleartext HTTP (`android:usesCleartextTraffic="true"`) hanya di
  `android/app/src/debug/AndroidManifest.xml` dan `.../profile/AndroidManifest.xml`
  agar backend dev (10.0.2.2 pada emulator, atau IP LAN laptop) yang berjalan
  `http://` tetap bisa diakses.

### Mengubah cleartext untuk build release

Build release TIDAK mengizinkan cleartext (aman secara bawaan). Saat backend
sudah dipasang di server memakai HTTPS (misalnya `https://api.namaku.example`)
tidak ada yang perlu diubah — request HTTPS lolos tanpa konfigurasi khusus.
Yang perlu dipastikan saat rilis:

1. Semua URL di aplikasi memakai `https://` (base URL via flavor/env, bukan
   `10.0.2.2`).
2. Jangan pindahkan `usesCleartextTraffic` ke manifest utama.
3. Bila suatu saat memang dibutuhkan HTTP untuk host tertentu di produksi
   (tidak disarankan), gunakan network security config berbasis domain,
   bukan `usesCleartextTraffic` global:
   buat `android/app/src/main/res/xml/network_security_config.xml` berisi
   `<domain-config cleartextTrafficPermitted="false">` per-domain, dan referensikan
   di manifest utama lewat `android:networkSecurityConfig`.

## FILE YANG HARUS DITUKAR (placeholder di-commit)

- `assets/brand/logo.png` — saat ini adalah **PLACEHOLDER** yang digenerate
  lewat skrip (lingkaran Moonstone/Vanilla di latar putih, 1024x1024).
  Sediakan logo asli resolusi 1024x1024 dengan nama yang sama:
  `assets/brand/logo.png`. Setelah diganti, jalankan ulang:
  - `dart run flutter_launcher_icons`
  - `dart run flutter_native_splash:create`
- Ikon launcher di `android/app/src/main/res/mipmap-*/ic_launcher.png`
  dan `ios/Runner/Assets.xcassets/AppIcon.appiconset/` saat ini juga berasal
  dari logo placeholder.

- `l10n.yaml` dihapus. Ia tidak pernah dipakai oleh codegen Flutter (key
  `main arb`/`arb-directories` bukan opsi valid `flutter gen-l10n`, dan
  file ARB berada di root, bukan di `lib/l10n/directory` yang ia tunjuk).
  L10n riil memakai dictionary hand-written di `lib/l10n/app_localizations.dart`
  dengan `app_id.arb` di root sebagai daftar kunci/terjemahan. Kehadiran
  `l10n.yaml` tanpa `flutter: generate: true` memicu kegagalan
  `gen_localizations` pada `flutter build apk`. Bila kelak ingin memakai
  codegen resmi, tambahkan `generate: true` di pubspec dan tulis ulang
  `l10n.yaml` dengan opsi valid (arb-dir: lib/l10n, template-arb-file: app_id.arb).

## Implementasi Fase E — sudah dikerjakan (10 November 2026)

### Flutter

- `lib/core/session_policy.dart` — kebijakan murni (Dart tanpa Flutter).
  `SessionPolicy.maxIdle = Duration(days: 60)` adalah sumber tunggal batas
  idle. `evaluate()` mengembalikan `sealed SessionDecision`:
  `NeedsOnboarding` → `NeedsLogin(reason)` → `Authenticated`. Jam mundur
  (`now` lebih awal dari `lastActiveAt`) tidak menggugurkan sesi — selisih
  negatif dianggap masih dalam batas; `touch()` juga menolak menurunkan
  `lastActiveAt` (anti jam mundur di dua lapis).
- `lib/services/session_store.dart` — abstrak `SessionStore` +
  `SharedPreferencesSessionStore` (token lewat `TokenStorage`, `lastActiveAt`
  + email terakhir di SharedPreferences) dan `InMemorySessionStore` untuk
  test/demo. `touch(now)` tulis `lastActiveAt` maksimal sekali per jam
  (`kTouchThrottle = Duration(hours: 1)`). `hapusSesi()` menghapus token
  dan `lastActiveAt` tetapi **mempertahankan email** untuk prefill login.
- Splash: `lib/features/splash/presentation/` — `SplashScreen` (kartu kaca
  berisi logo) + `SplashNotifier`: durasi minimal disuntik
  (bawaan 1200 ms), `warmUp` (pemanasan cache token ApiClient) berjalan
  fire-and-forget dengan batas maksimal 4 s, offline-first (tidak memanggil
  jaringan sebelum navigasi). Hasil evaluasi `SessionPolicy` dipublikasikan
  ke keeper, dipastikan durasi minimal, lalu navigasi.
- Routing: `lib/routing/session_keeper.dart` — `ruteSesi(decision)` memetakan
  keputusan ke rute (`NeedsOnboarding` → `/onboarding`, `NeedsLogin` →
  `/login?reason=…`, `Authenticated` → `/beranda`); `SessionKeeper` adalah
  `ChangeNotifier` yang dipakai GoRouter sebagai `refreshListenable`. Guard
  membaca `{currentRoute, decision, splashSelesai}` sehingga splash tidak
  bisa dilewati langsung ke dalam.
- Login: ketika `reason=kedaluwarsa`, login menampilkan banner "Sesi kamu
  sudah berakhir" (kunci l10n `SesiKedaluwarsa`) dan mengisi surel terakhir.
- Wiring 401: `sambungkanPengecualian401` di `lib/bootstrap.dart`
  (`lib/data/api/api_client.dart` meneruskan `UnauthorizedInfo{path, code}`):
  - 401 dari `/auth/login` atau `/auth/register` diabaikan (kredensial
    salah — bukan kedaluwarsa; pesan form yang tampil);
  - 401 dengan `code: session_expired` → `hapusSesi()` + `keeper.
    kedaluwarsakan()` → login dengan banner;
  - 401 lain pada endpoint terproteksi → `hapusSesi()` +
    `NeedsLogin(pertamaKali)` → login polos tanpa banner.

### Backend

- `AuthController` register/login: `createToken('mobile', ['*'],
  now()->addDays(60))`. Sanctum 4 Guard sudah menolak token dengan
  `expires_at` lewat.
- `App\Http\Middleware\RenewSessionToken` pada grup `auth:sanctum`:
  perpanjang `expires_at` token ke *sekarang + 60 hari*, tulis DB
  di-throttle lewat Cache (kunci `renew-session:{id}`, 60 menit,
  `updateQuietly`).
- `bootstrap/app.php`: render `AuthenticationException` membedakan via
  `PersonalAccessToken::findToken` (mendukung format `{id}|{hash}` dan
  plain): token terdaftar dengan `expires_at` lewat → 401
  `code: session_expired`; selain itu 401 lama `TIDAK_TERAUTENTIKASI`.
- `routes/console.php`: `Schedule::command('sanctum:prune-expired',
  ['--hours' => 24])->daily()` — token kedaluwarsa lebih dari 24 jam
  dihapus dari DB.
- **Catatan produksi:** driver Cache tidak boleh `null`/`none` karena
  throttle perpanjangan `RenewSessionToken` memakai Cache.

### Pengujian yang menyertai

`flutter test` kini berjumlah 156 (sebelumnya 108). Test baru yang
menyertai: `core/session_policy_test.dart` (9), `services/session_store_test.dart`
(9), `features/splash/` notifier (6) + screen (3),
`data/api/unauthorized_listener_test.dart` (3 kasus 401), dan
`routing/redirect_guard_test.dart` kini berisi 24 test (sebelumnya 8) —
keputusan sesi + kedaluwarsa. Backend menambah `SessionExpiryTest` (6)
dan `PruneExpiredScheduleTest` (1). Angka lengkap di `docs/hasil-pengujian.md`.

## Sisa pekerjaan

- `assets/brand/logo.png` masih **placeholder**; setelah logo asli disediakan
  jalankan ulang `dart run flutter_launcher_icons` dan
  `dart run flutter_native_splash:create`.
- Uji manual emulator/perangkat: alur login pertama → buka ulang < 60 hari
  (langsung dashboard) → lewat 60 hari (diminta login dengan banner) —
  daftar periksa di `docs/uji-manual.md` §3, **belum dijalankan**.
