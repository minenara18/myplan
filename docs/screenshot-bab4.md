# Daftar Screenshot untuk Bab IV

Daftar tangkapan layar yang perlu diambil untuk laporan Bab IV. Nama file
mengikuti pola `docs/screenshots/<nomor>-<deskripsi>.png`. Ubah nomor subbab
agar cocok dengan struktur bab laporan akhir.

Skenario menampilkan angka akurat (mode fake, `USE_FAKE=true`) dengan data demo
myPlan: mata kuliah diisi 3 buah, tugas beberapa buah, tanggal menyesuaikan
hari pengambilan layar (jam tetap FakeClock tidak berlaku di app sungguhan).

| # | Nama layar | Kondisi/konfigurasi | Kaitan subbab |
| --- | --- | --- | --- |
| 1 | Onboarding slide 1 | Aplikasi baru dibuka, sebelum login | Implementasi aplikasi (alur masuk) |
| 2 | Login (mode fake) | Isian email/password kosong; tombol Google | Alur autentikasi |
| 3 | Beranda | Setelah login; sapaan, progres hari ini, kartu fokus, aksi cepat | Implementasi aplikasi (beranda) |
| 4 | Tasks (daftar) | Filter "Hari ini"/"Minggu ini"; beberapa tugas, satu selesai (tercoret) | Implementasi aplikasi (tugas) |
| 5 | Form tambah tugas | Mata kuliah, tenggat, prioritas diisi | Implementasi aplikasi (tugas) |
| 6 | Calendar hari biasa | Strip minggu + sesi manual + tombol "Tambah Sesi" | Implementasi aplikasi (kalender) |
| 7 | Bottom sheet tambah sesi | Dropdown mata kuliah, jam (showTimePicker), chip durasi 30/45/60/90 | Implementasi aplikasi (kalender) |
| 8 | AI planner kosong | Keterangan waktu luang "16.00 – 21.00"; baris masukan + mic placeholder | Integrasi AI |
| 9 | AI planner loading | Skeleton timeline (3 kartu kaca) | Integrasi AI |
| 10 | AI planner hasil | Daftar blok kartu; tombol "Terapkan ke Kalender" | Integrasi AI |
| 11 | Kalender setelah terapkan | Sesi ber-*sumber* AI masuk ke hari terpilih | Integrasi AI |
| 12 | Ringkas Materi | Isian teks materi; tombol Ringkas | Integrasi AI |
| 13 | Hasil ringkas materi | Ringkasan, poin, 5 pertanyaan; tombol simpan sebagai catatan | Integrasi AI |
| 14 | Focus Timer siap | Durasi 25 menit; pilihan durasi; kontrol | Implementasi aplikasi (fokus) |
| 15 | Focus Timer berjalan | Lingkaran progres diisi; teks "Berjalan" | Implementasi aplikasi (fokus) |
| 16 | Progres | Kartu statistik + chart mingguan + streak | Implementasi aplikasi (progres) |
| 17 | Profil | Pengaturan: pengingat, durasi Pomodoro, waktu luang; tombol Keluar | Implementasi aplikasi (profil) |
| 18 | Dialog konfirmasi keluar | AlertDialog konfirmasi | Implementasi aplikasi (profil) |
| 19 | Layar dengan skala teks 2.0 (contoh: Tasks) | `adb shell settings put system font_scale 2.0` | Pengujian aksesibilitas |
| 20 | Hasil uji `flutter test` | Terminal `+108: All tests passed!` | Pengujian |
| 21 | Hasil uji backend | Terminal `php artisan test` (29 test, 142 assertion) | Pengujian |
| 22 | DevTools performance | Trace frame saat gulir daftar Tugas (profile mode) | Pengujian (kualitas) |

Screenshot yang **tidak bisa diambil saat ini**:

- Jalankan di emulator/perangkat — belum tersedia; seluruh tangkapan layar di
  atas masih perlu diambil setelah emulator dipasang (lihat
  `docs/uji-manual.md`).
- Splash Flutter tidak ada di kode (rencana Fase E, `docs/sesi.md`) — hanya ada
  splash natif putih + logo placeholder.
