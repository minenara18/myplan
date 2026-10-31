<?php

namespace Tests\Feature;

use App\Contracts\AiProvider;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Support\FakeAiProvider;
use Tests\TestCase;

final class AiSummarizeTest extends TestCase
{
    use RefreshDatabase;

    private const TEKS = <<<'TEKS'
Basis data adalah kumpulan data terorganisir yang dikelola sistem manajemen basis data.
Model relasional menyimpan data dalam tabel dengan baris dan kolom. Normalisasi
mengurangi redundansi dengan memisahkan data ke tabel dengan kunci asing. Indeks
mempercepat pencarian dengan struktur B-tree. Transaksi menjamin properti ACID:
atomik, konsisten, terisolasi, dan tahan gagal.
TEKS;

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

    /** @param array<string, mixed> $data */
    private function kirim(array $data, string $token)
    {
        return $this->postJson('/api/ai/summarize', $data, [
            'Authorization' => 'Bearer '.$token,
        ]);
    }

    public function test_llm_valid_mengembalikan_ringkasan_poin_dan_lima_pertanyaan(): void
    {
        $token = $this->daftarDanAmbilToken('sum-a@example.com');

        $fake = FakeAiProvider::menjawab(json_encode([
            'ringkasan' => 'Basis data menyimpan data terstruktur. Normalisasi mengurangi redundansi.',
            'poin_kunci' => ['Model relasional memakai tabel.', 'Indeks memakai B-tree.'],
            'pertanyaan_latihan' => [
                'Apa itu normalisasi 1NF?', 'Apa properti ACID?',
                'Kapan indeks justru melemahkan tulisan?',
                'Apa perbedaan primary dan foreign key?',
                'Mengapa transaksi harus terisolasi?',
            ],
        ]));
        $this->app->instance(AiProvider::class, $fake);

        $respons = $this->kirim(['teks' => self::TEKS], $token);

        $respons->assertStatus(200)
            ->assertJsonStructure([
                'data' => ['ringkasan', 'poin_kunci', 'pertanyaan_latihan'],
            ])
            ->assertJsonPath('data.pertanyaan_latihan.4', 'Mengapa transaksi harus terisolasi?');

        $this->assertDatabaseHas('ai_plans', ['status' => 'selesai']);
    }

    public function test_keluaran_llm_buruk_mengembalikan_ai_gagal(): void
    {
        $token = $this->daftarDanAmbilToken('sum-b@example.com');

        $this->app->instance(AiProvider::class, FakeAiProvider::menjawab('Bukan JSON sama sekali.'));

        $this->kirim(['teks' => self::TEKS], $token)
            ->assertStatus(502)
            ->assertJsonFragment(['code' => 'AI_GAGAL']);

        $this->assertDatabaseHas('ai_plans', ['status' => 'gagal']);
    }

    public function test_teks_terlalu_pendek_ditolak_validasi(): void
    {
        $token = $this->daftarDanAmbilToken('sum-c@example.com');

        $this->kirim(['teks' => 'terlalu pendek'], $token)
            ->assertStatus(422)
            ->assertJsonFragment(['code' => 'VALIDASI_GAGAL']);
    }

    public function test_butuh_autentikasi(): void
    {
        $this->postJson('/api/ai/summarize', ['teks' => self::TEKS])
            ->assertStatus(401);
    }

    public function test_llm_melempar_kesalahan_mengembalikan_502(): void
    {
        $token = $this->daftarDanAmbilToken('sum-d@example.com');

        $this->app->instance(AiProvider::class, FakeAiProvider::gagal());

        $this->kirim(['teks' => self::TEKS], $token)
            ->assertStatus(502)
            ->assertJsonFragment(['code' => 'AI_GAGAL']);
    }
}
