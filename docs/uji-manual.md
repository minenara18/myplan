# Uji Manual — Bagian B (di perangkat, dikerjakan sendiri)

Dokumen ini adalah daftar periksa uji manual yang **dikerjakan sendiri di
emulator/perangkat fisik** — bagian ini tidak bisa digantikan test otomatis.
Kolom "Hasil" dikosongkan dan diisi saat menjalankan.

Sebelum mulai:

```powershell
flutter run --dart-define=USE_FAKE=true   # mode demo tanpa backend
# atau, untuk backend:
flutter run --dart-define=USE_FAKE=false --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

## 1. Kelancaran (jank) dengan DevTools profile mode

| # | Langkah | Hasil yang diharapkan | Hasil (diisi sendiri) |
| --- | --- | --- | --- |
| 1.1 | `flutter run --profile`, buka DevTools > Performance, geser daftar Tugas pelan dan cepat | Tidak ada deretan frame gelap (>16 ms) saat gulir normal | |
| 1.2 | Cek raster thread saat berpindah tab di bar bawah | BackdropFilter hanya di bar bawah dan kartu hero; raster tetap di bawah 16 ms pada perangkat uji | |
| 1.3 | Buka layar AI lalu susun rencana (daftar kartu glass) | Item daftar tidak memakai blur (varian standard), gulir tetap halus | |
| 1.4 | Buka Progres, geser antar hari pada chart mingguan | Animasi chart tidak membuat beberapa frame beruntun melewati 16 ms | |

## 2. Sapuan visual — skala teks dan reduce motion

Set skala teks terbesar di pengaturan Android (*Display > Font size*, atau
`adb shell settings put system font_scale 2.0`), lalu sapukan semua layar:

| # | Layar | Yang diperiksa | Hasil |
| --- | --- | --- | --- |
| 2.1 | Splash natif → Login → Onboarding | Tidak ada teks terpotong; tombol tinggi ≥48 px | |
| 2.2 | Beranda | Sapaan, "Progres Hari Ini", kartu fokus, aksi cepat (Wrap) terbaca penuh | |
| 2.3 | Tasks | Judul kartu membungkus; chip tenggat + prioritas melipat ke baris baru, tidak terpotong | |
| 2.4 | Calendar | Chip hari pada strip minggu ikut membesar; kartu sesi "jam • durasi" membungkus | |
| 2.5 | AI planner | Judul dan keterangan membungkus; baris "waktu luang" membungkus pada skala 2.0 | |
| 2.6 | Ringkas Materi | Isian, tombol ringkas, dan hasil terbaca penuh | |
| 2.7 | Focus Timer | Lingkaran timer ikut membesar sesuai skala teks; semua kontrol terlihat | |
| 2.8 | Progres | Kartu statistik dan chart terbaca saat digulir | |
| 2.9 | Profil | Item pengaturan terbaca; nilai "16:00 - 21:00" tidak terpotong | |

Reduce motion (Android *Accessibility > Remove animations* aktif):

| # | Yang diperiksa | Harapan | Hasil |
| --- | --- | --- | --- |
| 2.10 | Perpindahan tab bar bawah | Konten langsung ke keadaan akhir, tanpa animasi lama | |
| 2.11 | Skeleton layar AI (kondisi Loading) | Tetap informatif tanpa dapat mengganggu mata | |

## 3. Alur sesi 60 hari & splash (rencana Fase E — belum ada kodenya)

Sesuai `docs/sesi.md`, sliding session dan layar splash belum
diimplementasikan. Daftar periksa untuk saat fase E dikerjakan:

| # | Skenario | Harapan | Hasil |
| --- | --- | --- | --- |
| 3.1 | Login, tutup app, buka lagi di hari yang sama | Masuk langsung tanpa login ulang | |
| 3.2 | Majukan tanggal perangkat 61 hari, buka app | Diminta login ulang; email terakhir terisi (prefill) | |
| 3.3 | App dibuka tiap hari < 60 hari | Sesi terus diperbarui (touch dibatasi sekali per jam) | |
| 3.4 | Splash | Splash natif putih + logo tampil sebelum route pertama | |

## 4. Alur mode fake

| # | Skenario | Harapan | Hasil |
| --- | --- | --- | --- |
| 4.1 | `USE_FAKE=true`, alur login → tambah tugas | Tugas tampil di layar Tugas | |
| 4.2 | Susun rencana AI → terapkan | Sesi tampil di Kalender dengan sumber "AI" | |
| 4.3 | Mulai Focus Timer sampai selesai | Rekaman fokus bertambah di Progres (streak muncul) | |
| 4.4 | Hot restart aplikasi | Data repo fake kembali ke data awal (diharapkan, mode demo) | |
