<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class OwnershipTest extends TestCase
{
    use RefreshDatabase;

    private function registerAndGetToken(string $email): string
    {
        /** @var string $token */
        $token = $this->postJson('/api/auth/register', [
            'name' => 'Pengguna '.md5($email),
            'email' => $email,
            'password' => 'password',
        ])->assertStatus(201)->json('data.token');

        return (string) $token;
    }

    /** @return array<string, array<int, string>> header auth untuk dua pemain */
    private function players(): array
    {
        return [
            'A' => ['Authorization' => 'Bearer '.$this->registerAndGetToken('a@example.com')],
            'B' => ['Authorization' => 'Bearer '.$this->registerAndGetToken('b@example.com')],
        ];
    }

    public function test_data_mata_kuliah_diekeringkan_per_pengguna(): void
    {
        $players = $this->players();

        $courseId = $this->postJson('/api/courses', [
            'nama' => 'Pemrograman Mobile',
            'warna_index' => 0,
        ], $players['A'])->assertStatus(201)->json('data.id');

        // B tidak melihat course milik A.
        $this->getJson('/api/courses', $players['B'])
            ->assertStatus(200)
            ->assertJsonMissing(['nama' => 'Pemrograman Mobile']);

        // B tidak bisa membaca course milik A.
        $this->getJson("/api/courses/{$courseId}", $players['B'])
            ->assertStatus(404);

        // B tidak bisa mengubah atau menghapus course milik A.
        $this->putJson("/api/courses/{$courseId}", ['nama' => 'Diretas'], $players['B'])
            ->assertStatus(404);
        $this->deleteJson("/api/courses/{$courseId}", [], $players['B'])
            ->assertStatus(404);

        // Data A tetap utuh.
        $this->getJson("/api/courses/{$courseId}", $players['A'])
            ->assertStatus(200)
            ->assertJsonPath('data.nama', 'Pemrograman Mobile');
    }

    public function test_tugas_milik_user_a_tidak_bisa_dibaca_dan_diubah_user_b(): void
    {
        $players = $this->players();

        $courseIdA = $this->postJson('/api/courses', [
            'nama' => 'Basis Data',
        ], $players['A'])->json('data.id');
        $courseIdB = $this->postJson('/api/courses', [
            'nama' => 'Jaringan Komputer',
        ], $players['B'])->json('data.id');

        $taskA = $this->postJson('/api/tasks', [
            'course_id' => $courseIdA,
            'judul' => 'Tugas ERD',
            'tenggat' => '2026-11-05T10:00:00.000Z',
            'estimasi_menit' => 90,
            'prioritas' => 'sedang',
            'status' => 'belum',
        ], $players['A'])->assertStatus(201)->json('data.id');

        // B tidak bisa melihat dan mengubah tugas A.
        $this->getJson("/api/tasks/{$taskA}", $players['B'])->assertStatus(404);
        $this->putJson("/api/tasks/{$taskA}", ['status' => 'selesai'], $players['B'])
            ->assertStatus(404);
        $this->deleteJson("/api/tasks/{$taskA}", [], $players['B'])->assertStatus(404);

        // B tidak boleh membuat tugas dengan course milik A.
        $this->postJson('/api/tasks', [
            'course_id' => $courseIdA,
            'judul' => 'Tugas ilegal',
            'tenggat' => '2026-11-05T10:00:00.000Z',
            'estimasi_menit' => 30,
            'prioritas' => 'tinggi',
            'status' => 'belum',
        ], $players['B'])->assertStatus(422);
    }

    public function test_sesi_milik_user_a_tak_bisa_disentuh_user_b(): void
    {
        $players = $this->players();

        $courseId = $this->postJson('/api/courses', ['nama' => 'AI'], $players['A'])
            ->json('data.id');

        $sessionId = $this->postJson('/api/sessions', [
            'course_id' => $courseId,
            'mulai' => '2026-11-01T09:00:00.000Z',
            'selesai' => '2026-11-01T11:00:00.000Z',
            'sumber' => 'manual',
        ], $players['A'])->assertStatus(201)->json('data.id');

        $this->getJson("/api/sessions/{$sessionId}", $players['B'])->assertStatus(404);
        $this->deleteJson("/api/sessions/{$sessionId}", [], $players['B'])->assertStatus(404);

        // B tidak melihat sesi A di indeks.
        $this->getJson('/api/sessions', $players['B'])
            ->assertStatus(200)
            ->assertJsonCount(0, 'data');
    }

    public function test_focus_record_milik_user_a_tak_bisa_dihapus_user_b(): void
    {
        $players = $this->players();

        $courseId = $this->postJson('/api/courses', ['nama' => 'AI'], $players['A'])
            ->json('data.id');
        $taskId = $this->postJson('/api/tasks', [
            'course_id' => $courseId,
            'judul' => 'Tugas Chatbot',
            'tenggat' => '2026-11-02T10:00:00.000Z',
            'estimasi_menit' => 60,
            'prioritas' => 'tinggi',
            'status' => 'belum',
        ], $players['A'])->json('data.id');

        $recordId = $this->postJson('/api/focus-records', [
            'task_id' => $taskId,
            'mulai' => '2026-11-03T10:00:00.000Z',
            'durasi_menit' => 25,
        ], $players['A'])->assertStatus(201)->json('data.id');

        $this->deleteJson("/api/focus-records/{$recordId}", [], $players['B'])
            ->assertStatus(404);

        $this->getJson('/api/focus-records', $players['B'])
            ->assertStatus(200)
            ->assertJsonCount(0, 'data');
    }

    public function test_stats_weekly_hanya_menghitung_data_pemohon(): void
    {
        $players = $this->players();

        $courseId = $this->postJson('/api/courses', ['nama' => 'AI'], $players['A'])
            ->json('data.id');

        // A punya satu rekaman fokus 45 menit.
        $this->postJson('/api/focus-records', [
            'mulai' => now()->startOfWeek()->addDays(1)->format('Y-m-d\TH:i:s'),
            'durasi_menit' => 45,
        ], $players['A'])->assertStatus(201);

        // B punya 30 menit.
        $this->postJson('/api/focus-records', [
            'task_id' => null,
            'mulai' => now()->startOfWeek()->addDays(1)->format('Y-m-d\TH:i:s'),
            'durasi_menit' => 30,
        ], $players['B'])->assertStatus(201);

        $this->getJson('/api/stats/weekly', $players['A'])
            ->assertStatus(200)
            ->assertJsonPath('data.total_menit', 45);

        $this->getJson('/api/stats/weekly', $players['B'])
            ->assertStatus(200)
            ->assertJsonPath('data.total_menit', 30);
    }

    public function test_semua_endpoint_data_membutuhkan_autentikasi(): void
    {
        $this->getJson('/api/courses')->assertStatus(401);
        $this->getJson('/api/tasks')->assertStatus(401);
        $this->getJson('/api/sessions')->assertStatus(401);
        $this->getJson('/api/focus-records')->assertStatus(401);
        $this->getJson('/api/stats/weekly')->assertStatus(401);
        $this->getJson('/api/settings')->assertStatus(401);
    }
}
