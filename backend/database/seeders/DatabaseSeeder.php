<?php

namespace Database\Seeders;

use App\Models\Course;
use App\Models\FocusRecord;
use App\Models\StudySession;
use App\Models\Task;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;

// Seed data mengikuti data awal Fake di aplikasi Flutter
// (FakeCourseRepository, FakeTaskRepository, FakeSessionRepository,
// FakeFocusRepository). Tenggat dibuat relatif terhadap waktu sekarang.
final class DatabaseSeeder extends Seeder
{
    /** course-1..course-4 pada Flutter Fake. */
    private const COURSES = [
        ['nama' => 'Pemrograman Mobile', 'warna_index' => 0],
        ['nama' => 'Basis Data', 'warna_index' => 1],
        ['nama' => 'Jaringan Komputer', 'warna_index' => 2],
        ['nama' => 'Kecerdasan Buatan', 'warna_index' => 3],
    ];

    public function run(): void
    {
        $users = collect([
            [
                'name' => 'Pengguna Demo',
                'email' => 'demo@example.com',
                'password' => 'password',
            ],
            [
                'name' => 'Pengguna Kedua',
                'email' => 'second@example.com',
                'password' => 'password',
            ],
            [
                'name' => 'Pengguna Ketiga',
                'email' => 'third@example.com',
                'password' => 'password',
            ],
        ]);

        $now = Carbon::now()->startOfHour();

        $users->each(function (array $userData) use ($now) {
            $user = User::firstOrCreate(
                ['email' => $userData['email']],
                [
                    'name' => $userData['name'],
                    'password' => $userData['password'],
                    'settings' => [
                        'reminder_enabled' => true,
                        'default_pomodoro_minutes' => 25,
                        'daily_free_time_start' => 16,
                        'daily_free_time_end' => 21,
                    ],
                ]
            );

            $courses = collect(self::COURSES)->map(fn (array $c) => Course::create([
                'user_id' => $user->id,
                'nama' => $c['nama'],
                'warna_index' => $c['warna_index'],
                'ikon' => 0xe800,
            ]))->values();

            $tasks = Task::create([
                'user_id' => $user->id,
                'course_id' => $courses[0]->id,
                'judul' => 'Tugas Flutter UI',
                'catatan' => 'Buat layar onboarding dan autentikasi',
                'tenggat' => (clone $now)->addDays(3),
                'estimasi_menit' => 120,
                'prioritas' => 'tinggi',
                'status' => 'berjalan',
            ]);

            Task::create([
                'user_id' => $user->id,
                'course_id' => $courses[1]->id,
                'judul' => 'Tugas ERD',
                'catatan' => 'Desain skema basis data mahasiswa',
                'tenggat' => (clone $now)->addDays(5),
                'estimasi_menit' => 90,
                'prioritas' => 'sedang',
                'status' => 'belum',
            ]);

            Task::create([
                'user_id' => $user->id,
                'course_id' => $courses[2]->id,
                'judul' => 'Tugas Subnetting',
                'catatan' => 'Hitung subnet untuk jaringan kampus',
                'tenggat' => (clone $now)->addDays(2),
                'estimasi_menit' => 60,
                'prioritas' => 'tinggi',
                'status' => 'belum',
            ]);

            Task::create([
                'user_id' => $user->id,
                'course_id' => $courses[3]->id,
                'judul' => 'Tugas Chatbot',
                'catatan' => 'Implementasi sederhana menggunakan AI',
                'tenggat' => (clone $now)->addDays(7),
                'estimasi_menit' => 180,
                'prioritas' => 'rendah',
                'status' => 'belum',
            ]);

            StudySession::create([
                'user_id' => $user->id,
                'course_id' => $courses[0]->id,
                'task_id' => $tasks->id,
                'mulai' => (clone $now)->subHours(2),
                'selesai' => (clone $now)->subHour(),
                'sumber' => 'manual',
            ]);

            StudySession::create([
                'user_id' => $user->id,
                'course_id' => $courses[1]->id,
                'task_id' => null,
                'mulai' => (clone $now)->subDay()->subHours(3),
                'selesai' => (clone $now)->subDay()->subHour(),
                'sumber' => 'ai',
            ]);

            FocusRecord::create([
                'user_id' => $user->id,
                'task_id' => $tasks->id,
                'mulai' => (clone $now)->subMinutes(45),
                'durasi_menit' => 45,
            ]);

            FocusRecord::create([
                'user_id' => $user->id,
                'task_id' => null,
                'mulai' => (clone $now)->subHours(3),
                'durasi_menit' => 25,
            ]);
        });
    }
}
