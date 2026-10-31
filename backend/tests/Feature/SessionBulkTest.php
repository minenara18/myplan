<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Tests\TestCase;

final class SessionBulkTest extends TestCase
{
    use RefreshDatabase;

    private function daftarDanAmbilToken(string $email): string
    {
        /** @var string $token */
        $token = $this->postJson('/api/auth/register', [
            'name' => 'Uji',
            'email' => $email,
            'password' => 'password',
        ])->assertStatus(201)->json('data.token');

        return (string) $token;
    }

    public function test_bisa_menyimpan_banyak_sesi_sekaligus(): void
    {
        $token = $this->daftarDanAmbilToken('bulk@example.com');
        $courseId = $this->postJson('/api/courses', ['nama' => 'Basis Data'], [
            'Authorization' => 'Bearer '.$token,
        ])->json('data.id');
        $taskId = $this->postJson('/api/tasks', [
            'course_id' => $courseId,
            'judul' => 'ERD',
            'tenggat' => Carbon::now()->addDays(3)->toIso8601String(),
            'estimasi_menit' => 60,
            'prioritas' => 'tinggi',
            'status' => 'belum',
        ], ['Authorization' => 'Bearer '.$token])->json('data.id');

        $respons = $this->postJson('/api/sessions/bulk', [
            'sesi' => [
                [
                    'course_id' => $courseId,
                    'task_id' => $taskId,
                    'mulai' => Carbon::now()->setHour(16)->toIso8601String(),
                    'selesai' => Carbon::now()->setHour(17)->toIso8601String(),
                    'sumber' => 'ai',
                ],
                [
                    'course_id' => $courseId,
                    'mulai' => Carbon::now()->addDay()->setHour(16)->toIso8601String(),
                    'selesai' => Carbon::now()->addDay()->setHour(18)->toIso8601String(),
                    'sumber' => 'manual',
                ],
            ],
        ], ['Authorization' => 'Bearer '.$token]);

        $respons->assertStatus(201)
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('data.0.sumber', 'ai')
            ->assertJsonPath('data.1.sumber', 'manual');

        $this->assertDatabaseCount('study_sessions', 2);
    }

    public function test_sesi_bukan_milik_pengguna_ditolak_seluruhnya(): void
    {
        $tokenA = $this->daftarDanAmbilToken('bulk-a@example.com');
        $tokenB = $this->daftarDanAmbilToken('bulk-b@example.com');

        $courseIdA = $this->postJson('/api/courses', ['nama' => 'Milik A'], [
            'Authorization' => 'Bearer '.$tokenA,
        ])->json('data.id');

        $this->postJson('/api/sessions/bulk', [
            'sesi' => [
                [
                    'course_id' => $courseIdA,
                    'mulai' => Carbon::now()->setHour(16)->toIso8601String(),
                    'selesai' => Carbon::now()->setHour(17)->toIso8601String(),
                    'sumber' => 'ai',
                ],
            ],
        ], ['Authorization' => 'Bearer '.$tokenB])
            ->assertStatus(422)
            ->assertJsonFragment(['code' => 'VALIDASI_GAGAL']);

        $this->assertDatabaseCount('study_sessions', 0);
    }

    public function test_butuh_autentikasi_dan_validasi_per_blok(): void
    {
        $this->postJson('/api/sessions/bulk', ['sesi' => []])
            ->assertStatus(401);

        $token = $this->daftarDanAmbilToken('bulk-valid@example.com');

        $this->postJson('/api/sessions/bulk', [
            'sesi' => [
                [
                    'course_id' => 1,
                    'mulai' => Carbon::now()->toIso8601String(),
                    'selesai' => Carbon::now()->setHour(8)->toIso8601String(),
                    'sumber' => 'manual',
                ],
            ],
        ], ['Authorization' => 'Bearer '.$token])
            ->assertStatus(422)
            ->assertJsonFragment(['code' => 'VALIDASI_GAGAL'])
            ->assertJsonStructure(['message', 'errors', 'code']);
    }
}
