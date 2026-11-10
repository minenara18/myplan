# Tabel Endpoint API

Sumber: `backend/routes/api.php` dan `docs/openapi.yaml`. Semua respons JSON.
Prefix `/api` (dari `bootstrap/app.php`) — dari aplikasi Flutter disesuaikan
lewat `--dart-define=API_BASE_URL` (default `http://10.0.2.2:8000/api`).

## Autentikasi (tanpa token)
| Method | Endpoint | Aksi | Keterangan |
| --- | --- | --- | --- |
| POST | `/auth/register` | Daftar akun baru | Nama, email, password; mengembalikan token Sanctum. |
| POST | `/auth/login` | Masuk | Email + password; mengembalikan token Sanctum. |

### Masa berlaku token (sesi 60 hari)

- Register/login membuat token berlaku **60 hari** (`expires_at = now() + 60 hari`).
- Setiap request terautentikasi memperpanjang `expires_at` ke *sekarang + 60 hari* (middleware `RenewSessionToken`), **maksimal sekali per jam per token** — tulis DB di-throttle lewat Cache (kunci `renew-session:{id}`).
- Lewat 60 hari tanpa dibuka, endpoint terproteksi mengembalikan 401 `code: session_expired`; 401 lain tetap `TIDAK_TERAUTENTIKASI`.
- Jadwal harian `sanctum:prune-expired --hours=24` membersihkan token yang kedaluwarsa lebih 24 jam (lihat `routes/console.php`).
- **Catatan produksi:** driver Cache **tidak boleh `null`/`none`** karena throttle perpanjangan token memakainya; di `config/cache.php` pilih database/redis/file.

## Dilindungi `auth:sanctum`

| Method | Endpoint | Aksi | Keterangan |
| --- | --- | --- | --- |
| POST | `/auth/logout` | Keluar | Token aktif dicabut. |
| GET | `/me` | Profil pengguna aktif | Nama + email. |
| GET | `/settings` | Pengaturan pengguna | `reminder_enabled`, `default_pomodoro_minutes`, `daily_free_time_start/end` (kolom JSON `users.settings`). |
| PUT | `/settings` | Perbarui pengaturan | Validasi tiap bidang. |
| GET | `/stats/weekly` | Statistik mingguan | Menit fokus & sesi per hari untuk chart Progres. |

### Mata kuliah (`apiResource courses`)

| Method | Endpoint | Aksi |
| --- | --- | --- |
| GET | `/courses` | Daftar mata kuliah milik pengguna. |
| POST | `/courses` | Buat mata kuliah. |
| GET | `/courses/{course}` | Detail mata kuliah. |
| PUT / PATCH | `/courses/{course}` | Perbarui mata kuliah. |
| DELETE | `/courses/{course}` | Hapus (cascade ke tugas & sesi). |

### Tugas (`apiResource tasks`)

| Method | Endpoint | Aksi |
| --- | --- | --- |
| GET | `/tasks` | Daftar tugas (bisa filter `course_id`). |
| POST | `/tasks` | Buat tugas. |
| GET | `/tasks/{task}` | Detail tugas. |
| PUT / PATCH | `/tasks/{task}` | Perbarui tugas (termasuk simpan catatan ringkasan AI). |
| DELETE | `/tasks/{task}` | Hapus tugas. |

### Sesi belajar

| Method | Endpoint | Aksi | Keterangan |
| --- | --- | --- | --- |
| POST | `/sessions/bulk` | Simpan banyak sesi sekaligus | Dipakai tombol "Terapkan ke Kalender" hasil AI; didefinisikan sebelum `apiResource` agar tidak tertangkap pola `{session}`. |
| GET | `/sessions` | Daftar sesi | Filter `course_id`, `mulai`, `sampai`. |
| POST | `/sessions` | Buat satu sesi (manual). | |
| GET | `/sessions/{session}` | Detail sesi. | |
| PUT / PATCH | `/sessions/{session}` | Perbarui sesi. | |
| DELETE | `/sessions/{session}` | Hapus sesi. | |

### Rekaman fokus

| Method | Endpoint | Aksi |
| --- | --- | --- |
| GET | `/focus-records` | Daftar rekaman fokus. |
| POST | `/focus-records` | Simpan rekaman fokus (`task_id` opsional). |
| DELETE | `/focus-records/{record}` | Hapus rekaman. |

### AI (throttled per pengguna)

| Method | Endpoint | Aksi | Throttle | Keterangan |
| --- | --- | --- | --- | --- |
| POST | `/ai/plan` | Susun rencana belajar | 5/menit | LLM kompatibel OpenAI; bila gagal memakai `DeterministicPlanner`. |
| POST | `/ai/summarize` | Ringkas materi | 10/menit | Maksimal 20 000 karakter teks. |

## Kode kesalahan utama

| Kode | Kondisi | Bentuk |
| --- | --- | --- |
| 401 | Token tidak valid, atau kedaluwarsa (`code: session_expired` bila lewat batas idle 60 hari) | Aplikasi menghapus token dan berbalik ke `/login` (dengan banner bila `session_expired`). |
| 422 | Galat validasi | `errors` per bidang; dipetakan jadi `ValidationFailure`. |
| 429 | Melebihi throttle (`/ai/*`) | Pesan batas laju lewat `Failure`. |
| 5xx / jaringan | Server atau koneksi mati | Dipetakan jadi `NetworkFailure` (kartu coba lagi di layar). |

Spesifikasi request/response lengkap: `docs/openapi.yaml`; koleksi pengujian
manual: `docs/postman/`.
