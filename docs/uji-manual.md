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

## 3. Alur sesi 60 hari & splash (Fase E — kodenya sudah ada)

Sliding session dan splash sudah diimplementasikan (lihat `docs/sesi.md`).
Daftar periksa ini dijalankan di emulator/perangkat dengan backend berjalan
(`USE_FAKE=false`); untuk kedaluwarsa, majukan tanggal perangkat terlebih
dahulu (jam fake), lalu buka aplikasi:

```powershell
# contoh majukan tanggal emulator Android (perlu adb root):
adb root; adb shell date 0109120000.00   # ke 9 Januari 12:00 (+61 hari dari 10 Nov)
# alternatif tanpa adb root: GUI emulator > Extended controls > Date & time
```

Catatan jam fake: selesai mengujinya, **kembalikan tanggal** perangkat —
jam mundur sengaja diabaikan oleh `SessionStore` (lastActiveAt tidak
pernah diturunkan), jadi tanggal yang keliru tidak merusak sesi asli.

| # | Skenario | Harapan | Hasil |
| --- | --- | --- | --- |
| 3.1 | Login, tutup app, buka lagi di hari yang sama | Splash Flutter tampil lalu langsung ke `/beranda` tanpa login ulang | |
| 3.2 | Tutup app, majukan jam perangkat 61 hari, buka app | Splash lalu diminta login dengan banner "Sesi kamu sudah berakhir"; email terakhir terisi (prefill) | |
| 3.3 | App dibuka tiap hari < 60 hari | Sesi terus diperbarui (touch dibatasi sekali per jam); tetap langsung ke `/beranda` | |
| 3.4 | Splash | Splash natif putih + logo tampil sebelum route pertama, lalu kartu kaca splash Flutter dengan animasi 600 ms | |
| 3.5 | Keluar (`/auth/logout`) mencabut token, lalu pakai app: request berikutnya 401 biasa | App menuju `/login` polos tanpa banner kedaluwarsa (rute `NeedsLogin(pertamaKali)`) | |

## 4. Alur mode fake

| # | Skenario | Harapan | Hasil |
| --- | --- | --- | --- |
| 4.1 | `USE_FAKE=true`, alur login → tambah tugas | Tugas tampil di layar Tugas | |
| 4.2 | Susun rencana AI → terapkan | Sesi tampil di Kalender dengan sumber "AI" | |
| 4.3 | Mulai Focus Timer sampai selesai | Rekaman fokus bertambah di Progres (streak muncul) | |
| 4.4 | Hot restart aplikasi | Data repo fake kembali ke data awal (diharapkan, mode demo) | |
