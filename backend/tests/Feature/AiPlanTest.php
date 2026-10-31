<?php

namespace Tests\Feature;

use App\Contracts\AiProvider;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Tests\Support\FakeAiProvider;
use Tests\TestCase;

final class AiPlanTest extends TestCase
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

    /** Bentuk jawaban JSON sesuai skema yang diminta dari LLM. */
    private function jawabJson(array $sesi, array $prioritas = []): string
    {
        return json_encode(
            ['sesi' => $sesi, 'prioritas' => $prioritas],
            JSON_UNESCAPED_UNICODE
        );
    }

    public function test_llm_valid_mengembalikan_sesi_dan_tercatat_di_ai_plans(): void
    {
        $this->travelTo(Carbon::now()->setHour(8));

        $token = $this->daftarDanAmbilToken('ai-plan@example.com');

        $courseId = $this->postJson('/api/courses', ['nama' => 'Kecerdasan Buatan'], [
            'Authorization' => 'Bearer '.$token,
        ])->json('data.id');

        $taskId = $this->postJson('/api/tasks', [
            'course_id' => $courseId,
            'judul' => 'Tugas Chatbot',
            'tenggat' => Carbon::now()->addDays(3)->toIso8601String(),
            'estimasi_menit' => 120,
            'prioritas' => 'tinggi',
            'status' => 'belum',
        ], ['Authorization' => 'Bearer '.$token])->json('data.id');

        $rentangMulai = Carbon::now()->toDateString();
        $blok = [
            'mulai' => Carbon::now()->setHour(16)->toIso8601String(),
            'selesai' => Carbon::now()->setHour(17)->toIso8601String(),
        ];

        $fake = FakeAiProvider::menjawab($this->jawabJson([[
            'task_id' => $taskId,
            'mulai' => $blok['mulai'],
            'selesai' => $blok['selesai'],
            'alasan' => 'Selesaikan dulu bagian kritisnya.',
        ]], [$taskId]));
        $this->app->instance(AiProvider::class, $fake);

        $respons = $this->postJson('/api/ai/plan', [
            'mulai' => $rentangMulai,
            'sampai' => Carbon::now()->addDays(2)->toDateString(),
            'jam_mulai' => 15,
            'jam_selesai' => 21,
        ], ['Authorization' => 'Bearer '.$token]);

        $respons->assertStatus(200)
            ->assertJsonPath('data.sumber', 'ai')
            ->assertJsonCount(1, 'data.sesi')
            ->assertJsonPath('data.sesi.0.task_id', (string) $taskId)
            ->assertJsonPath('data.sesi.0.alasan', 'Selesaikan dulu bagian kritisnya.')
            ->assertJsonPath('data.prioritas.0', (string) $taskId)
            ->assertJsonPath('data.rentang.mulai', $rentangMulai);

        $this->assertDatabaseCount('ai_plans', 1);
        $this->assertDatabaseHas('ai_plans', ['status' => 'selesai']);
    }

    public function test_blok_tidak_valid_dibuang_server(): void
    {
        $this->travelTo(Carbon::now()->setHour(8));

        $tukeranA = $this->daftarDanAmbilToken('plan-a@example.com');
        $tokenB = $this->daftarDanAmbilToken('plan-b@example.com');

        $courseId = $this->postJson('/api/courses', ['nama' => 'A'], [
            'Authorization' => 'Bearer '.$tukeranA,
        ])->json('data.id');
        $taskIdA = $this->postJson('/api/tasks', [
            'course_id' => $courseId,
            'judul' => 'Milik A',
            'tenggat' => Carbon::now()->addDays(3)->toIso8601String(),
            'estimasi_menit' => 60,
            'prioritas' => 'sedang',
            'status' => 'belum',
        ], ['Authorization' => 'Bearer '.$tukeranA])->json('data.id');

        $courseB = $this->postJson('/api/courses', ['nama' => 'B'], [
            'Authorization' => 'Bearer '.$tokenB,
        ])->json('data.id');
        $taskIdB = $this->postJson('/api/tasks', [
            'course_id' => $courseB,
            'judul' => 'Milik B',
            'tenggat' => Carbon::now()->addDays(3)->toIso8601String(),
            'estimasi_menit' => 60,
            'prioritas' => 'tinggi',
            'status' => 'belum',
        ], ['Authorization' => 'Bearer '.$tokenB])->json('data.id');

        // Sesi yang sudah ada hari ini jam 16 — blok menimpanya harus dibuang.
        $this->postJson('/api/sessions', [
            'course_id' => $courseB,
            'mulai' => Carbon::now()->setHour(16)->toIso8601String(),
            'selesai' => Carbon::now()->setHour(18)->toIso8601String(),
            'sumber' => 'manual',
        ], ['Authorization' => 'Bearer '.$tokenB])->assertStatus(201);

        $blokValid = [
            'task_id' => $taskIdB,
            'mulai' => Carbon::now()->setHour(18)->toIso8601String(),
            'selesai' => Carbon::now()->setHour(19)->toIso8601String(),
            'alasan' => 'Slot aman sesudah sesi lain.',
        ];
        $fake = FakeAiProvider::menjawab($this->jawabJson([
            ['task_id' => $taskIdA, 'mulai' => Carbon::now()->setHour(19)->toIso8601String(),
                'selesai' => Carbon::now()->setHour(20)->toIso8601String(), 'alasan' => 'Tugas user lain.'],
            ['task_id' => $taskIdB, 'mulai' => Carbon::now()->setHour(16)->toIso8601String(),
                'selesai' => Carbon::now()->setHour(17)->toIso8601String(), 'alasan' => 'Bentrok sesi yang ada.'],
            ['task_id' => $taskIdB, 'mulai' => Carbon::now()->setHour(20)->toIso8601String(),
                'selesai' => Carbon::now()->setHour(23)->toIso8601String(), 'alasan' => 'Di luar waktu luang.'],
            ['task_id' => $taskIdB, 'mulai' => 9999999999,
                'selesai' => 9999999999, 'alasan' => 'Format waktu jelek.'],
            $blokValid,
        ], [$taskIdA, $taskIdB]));
        $this->app->instance(AiProvider::class, $fake);

        $respons = $this->postJson('/api/ai/plan', [
            'mulai' => Carbon::now()->toDateString(),
            'sampai' => Carbon::now()->addDay()->toDateString(),
            'jam_mulai' => 15,
            'jam_selesai' => 21,
        ], ['Authorization' => 'Bearer '.$tokenB]);

        $respons->assertStatus(200)
            // Hanya blok yang sah yang lolos.
            ->assertJsonCount(1, 'data.sesi')
            ->assertJsonPath('data.sesi.0.task_id', (string) $taskIdB)
            ->assertJsonPath('data.prioritas', [(string) $taskIdB]);
    }

    public function test_llm_gagal_jatuh_ke_penjadwal_deterministik(): void
    {
        $this->travelTo(Carbon::now()->setHour(8));

        $token = $this->daftarDanAmbilToken('plan-cairo@example.com');
        $courseId = $this->postJson('/api/courses', ['nama' => 'Jaringan'], [
            'Authorization' => 'Bearer '.$token,
        ])->json('data.id');
        $taskId = $this->postJson('/api/tasks', [
            'course_id' => $courseId,
            'judul' => 'Tugas Subnetting',
            'tenggat' => Carbon::now()->addDays(2)->toIso8601String(),
            'estimasi_menit' => 60,
            'prioritas' => 'tinggi',
            'status' => 'belum',
        ], ['Authorization' => 'Bearer '.$token])->json('data.id');

        $this->app->instance(AiProvider::class, FakeAiProvider::gagal());

        $respons = $this->postJson('/api/ai/plan', [
            'mulai' => Carbon::now()->toDateString(),
            'sampai' => Carbon::now()->addDay()->toDateString(),
            'jam_mulai' => 15,
            'jam_selesai' => 21,
        ], ['Authorization' => 'Bearer '.$token]);

        $respons->assertStatus(200)
            ->assertJsonPath('data.sumber', 'fallback')
            ->assertJsonCount(1, 'data.sesi')
            ->assertJsonPath('data.sesi.0.task_id', (string) $taskId);

        $mulai = $respons->json('data.sesi.0.mulai');
        $this->assertNotNull($mulai);
        // Blok deterministik: di dalam jendela waktu luang (15-21) dan
        // dalam rentang yang diminta.
        $mulaiCarbon = Carbon::parse($mulai);
        $this->assertGreaterThanOrEqual(15, $mulaiCarbon->hour, 'Jam mulai di bawah jendela: '.$mulai);
        $this->assertLessThan(21, $mulaiCarbon->hour, 'Jam mulai di atas jendela: '.$mulai);
        $selesai = $respons->json('data.sesi.0.selesai');
        $this->assertTrue(Carbon::parse($selesai)->isSameDay($mulaiCarbon)
            || Carbon::parse($selesai)->isSameDay(Carbon::now()->addDay()), 'Selesai melewati tengah malam: '.$selesai);
        $this->assertDatabaseHas('ai_plans', ['status' => 'gagal']);
    }

    public function test_validasi_rentang_dilakukan_dulu(): void
    {
        $token = $this->daftarDanAmbilToken('plan-valid@example.com');

        $this->postJson('/api/ai/plan', [
            'sampai' => '2026-01-01',
        ], ['Authorization' => 'Bearer '.$token])
            ->assertStatus(422)
            ->assertJsonFragment(['code' => 'VALIDASI_GAGAL']);
    }

    public function test_butuh_autentikasi(): void
    {
        $this->postJson('/api/ai/plan', ['mulai' => '2026-01-01', 'sampai' => '2026-01-02'])
            ->assertStatus(401);
    }

    public function test_dibatasi_lima_panggilan_per_menit(): void
    {
        $token = $this->daftarDanAmbilToken('limit-plan@example.com');
        $this->app->instance(AiProvider::class, FakeAiProvider::gagal());

        $masukan = [
            'mulai' => Carbon::now()->toDateString(),
            'sampai' => Carbon::now()->addDay()->toDateString(),
        ];
        foreach (range(1, 5) as $i) {
            $this->postJson('/api/ai/plan', $masukan, ['Authorization' => 'Bearer '.$token])
                ->assertStatus(200);
        }

        $this->postJson('/api/ai/plan', $masukan, ['Authorization' => 'Bearer '.$token])
            ->assertStatus(429);
    }
}
