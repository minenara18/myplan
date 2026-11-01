# Setup PostgreSQL untuk backend MyPlan

Target: database `myplan_db` dengan user khusus aplikasi `myplan_user`.
Migration dev tetap dijalankan **setelah** kamu menyatakan siap — dokumen
ini hanya persiapan. (Hanya isi langkah SQL di bawah yang perlu password
kamu sendiri; password tidak boleh ditulis di dokumen ini.)

## 1. Buat user dan database

Masuk sebagai superuser Postgres (default `postgres`):

```
psql -U postgres
```

Lalu di psql:

```sql
-- ganti '...' dengan password kamu sendiri
CREATE ROLE myplan_user WITH LOGIN PASSWORD '...';

CREATE DATABASE myplan_db
  WITH OWNER myplan_user
  ENCODING 'UTF8'
  LC_COLLATE = 'C.UTF-8'
  LC_CTYPE = 'C.UTF-8'
  TEMPLATE template0;

GRANT ALL PRIVILEGES ON DATABASE myplan_db TO myplan_user;

-- Postgres 15+: role pemilik database perlu izin pada schema public
\c myplan_db
GRANT ALL ON SCHEMA public TO myplan_user;
```

Catatan: jika Windows error `LC_COLLATE` tidak dikenal, hapus baris
`LC_COLLATE`/`LC_CTYPE` dan biarkan default server.

## 2. Verifikasi koneksi

```
psql -U myplan_user -d myplan_db -h localhost
```

## 3. Isian `backend/.env`

```
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=myplan_db
DB_USERNAME=myplan_user
DB_PASSWORD={password yang kamu buat}
```

## 4. Setelah kamu bilang siap

```
cd backend
php artisan migrate
```

Jangan jalankan perintah di atas sendiri sebelum disetujui — instruksi tugas
adalah menunggu konfirmasi.

## Referensi keamanan

- Password DB hanya di `backend/.env` (sudah di-ignore git).
- Bahkan tidak perlu menulis password DB di komit — gunakan `.env.example`
  sebagai templat tanpa nilai.
