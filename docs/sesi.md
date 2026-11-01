# Catatan sesi 60 hari & splash (tahap sebelum Fase E)

Dokumen ini mencatat persiapan infrastruktur yang sudah dilakukan dan daftar
file yang perlu disediakan/diganti sebelum Fase E (implementasi sliding
session 60 hari, splash, dan pengetatan Sanctum `expires_at`).

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

## Rencana Fase E (belum dikerjakan di tahap ini)

- `lib/core/session_policy.dart` — kebijakan murni, `maxIdle = 60 hari`.
- `lib/services/session_store.dart` (+ Secure/InMemory) — token, lastActiveAt, email terakhir.
- Sliding session: `touch()` di cold start & resume background, throttle 1 jam.
- Splash: `lib/features/splash/` + konfigurasi `flutter_native_splash` (sudah
  dipasang sebagai dev dependency, latar putih + logo tengah).
- Routing: initial `/splash`, guard murni membaca `SessionDecision`.
- Backend: Sanctum `expires_at` (login = sekarang + 60 hari), middleware
  perpanjangan (throttle 1 jam/token), 401 `session_expired`.
- Login setelah kedaluwarsa: pesan l10n + prefill email terakhir.
