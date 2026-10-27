\# AI Study Planner

Aplikasi mobile perencana belajar mahasiswa, berbahasa Indonesia. Proyek magang: harus rapi, bisa didemokan, dan mudah dijelaskan di laporan.



\## Stack

Flutter (Dart 3), Riverpod 3 (Notifier/AsyncNotifier), GoRouter, Dio, fl\_chart. Backend (nanti): Laravel 12 + Sanctum + PostgreSQL di folder `backend/`. AI dipanggil lewat backend; kunci API tidak pernah ada di aplikasi.



\## Desain (acuan visual: docs/design/)

Bersih, minimalis, glassmorphism halus, ikon menggantikan teks, mode terang saja.

\- Moonstone #4C9DB0 primer, tint #7DBBCA. Vanilla #FFEBAF aksen/terpilih. Latar #FFFFFF di semua layar. Teks #1F2D3A, sekunder #6B7C88.

\- Kartu kaca: putih 60-70%, blur halus, garis tepi Moonstone 20%, bayangan Moonstone 15%, radius 20-24.

\- Judul serif DM Serif Display, isi Inter. Font dibundel di assets/fonts, bukan google\_fonts.

\- Ikon rounded line, stroke 1.75, satu paket saja (Lucide atau Material Symbols Rounded).

\- Grid 8pt, target sentuh minimal 48px, kontras WCAG AA.

\- Latar putih membuat kaca tidak terlihat, jadi siapkan 2-3 lingkaran Moonstone/Vanilla yang diburamkan di belakang panel. BackdropFilter hanya untuk bar navigasi, kartu hero, sheet, dan kartu login. Daftar panjang memakai panel semi-transparan tanpa blur.



\## Struktur (satu paket Flutter, feature-first)

lib/main.dart (tipis, memanggil bootstrap), bootstrap.dart, app.dart, core/ (Dart murni: model nilai, Result/Failure, Clock), data/ (repository dan sumber data), services/, routing/, theme/ (token dan komponen kaca di theme/components/), l10n/, features/<fitur>/presentation/ (screen, notifier, widgets/).

Aturan: fitur tidak mengimpor fitur lain; hanya package: imports; tanpa folder utils/helpers/common/misc; satu deklarasi utama per file, nama file = snake\_case dari deklarasi; test/ mencerminkan lib/.



\## Aturan kode

\- View hanya menampilkan state dari satu Notifier per fitur; aksi lewat method Notifier.

\- Repository adalah satu-satunya jalur baca/tulis data. Ada FakeRepository (in-memory) dan RemoteRepository (Dio), dipilih lewat provider override di bootstrap.

\- Kegagalan jaringan menjadi nilai (sealed Failure) dan ditampilkan lewat AsyncValue. Tidak ada catch kosong. Setelah await, cek mounted sebelum memakai context.

\- Waktu lewat Clock yang disuntik, bukan DateTime.now() di fitur.

\- Tidak ada warna, radius, durasi, atau ukuran font mentah di luar lib/theme/.

\- Teks UI lewat l10n (app\_id.arb), bukan literal di widget.

\- Widget berupa kelas const bernama, bukan method \_buildX(). Daftar memakai ListView.builder. Rebuild dipersempit dengan ref.watch(...select).

\- Ikon tanpa teks wajib punya Semantics atau tooltip. Warna tidak boleh jadi satu-satunya penanda status. Hormati reduce motion.



\## Alur kerja

Langkah selesai bila `flutter analyze` bersih dan `flutter test` hijau. Jangan menambah paket di luar daftar tanpa menyebut alasannya. Jangan mengerjakan di luar cakupan langkah. Di akhir, rangkum file yang dibuat dan hal yang belum selesai.

