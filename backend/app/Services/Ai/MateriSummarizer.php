<?php

namespace App\Services\Ai;

use App\Contracts\AiProvider;
use App\Exceptions\AiException;
use App\Models\User;
use Illuminate\Support\Facades\DB;

/**
 * Ringkas materi kuliah: satu panggilan LLM, keluaran divalidasi
 * di server — {ringkasan, poin_kunci[], pertanyaan_latihan[]}.
 * Gagal digali ke error seragam, tidak pernah mengembalikan data setengah matang.
 */
final class MateriSummarizer
{
    public function __construct(private readonly AiProvider $provider) {}

    /**
     * @param  int  $batasKarakter  batas untuk teks input
     * @return array{ringkasan: string, poin_kunci: array<int, string>, pertanyaan_latihan: array<int, string>}
     *
     * @throws AiException bila LLM gagal atau keluaran tidak sesuai skema
     */
    public function ringkas(User $user, string $teks, int $batasKarakter = 20_000): array
    {
        $promptSistem = <<<'TEKS'
Kamu penutor materi kuliah mahasiswa Indonesia. Balas HANYA JSON tanpa penjelasan, dengan bentuk:
{
  "ringkasan": "<3-6 kalimat>",
  "poin_kunci": ["<kalimat>", ...],
  "pertanyaan_latihan": ["<pertanyaan>", ...]
}
Isi poin_kunci dengan 3-6 butir dan pertanyaan_latihan tepat 5 butir.
TEKS;
        $promptUser = 'Ringkas materi berikut.'.PHP_EOL.PHP_EOL.$teks;

        $tercatat = false;

        try {
            $jawaban = $this->provider->selesaikan($promptSistem, $promptUser, null);
            $json = $this->tarikJson($jawaban);

            if ($json === null) {
                throw AiException::gagal('Respons LLM bukan JSON.');
            }

            $hasil = $this->format($json);
        } catch (AiException $e) {
            $this->catat($user, $promptUser, ['kesalahan' => $e->getMessage()], 'gagal');

            throw $e;
        }

        $this->catat($user, $promptUser, $hasil, 'selesai');

        return $hasil;
    }

    /**
     * @param  array<mixed>  $json
     * @return array{ringkasan: string, poin_kunci: list<string>, pertanyaan_latihan: list<string>}
     */
    private function format(array $json): array
    {
        $ringkasan = is_string($json['ringkasan'] ?? null) ? trim($json['ringkasan']) : '';
        $poin = $this->saringTeks($json['poin_kunci'] ?? null);
        $pertanyaan = $this->saringTeks($json['pertanyaan_latihan'] ?? null);

        if ($ringkasan === '' || $poin === [] || $pertanyaan === []) {
            throw AiException::gagal('Keluaran LLM tidak lengkap.');
        }

        return [
            'ringkasan' => $ringkasan,
            'poin_kunci' => array_slice($poin, 0, 6),
            'pertanyaan_latihan' => array_slice($pertanyaan, 0, 5),
        ];
    }

    /** Bidang array yang berisi teks teks — buang yang bukan teks atau kosong. */
    private function saringTeks(mixed $bidang): array
    {
        if (! is_array($bidang)) {
            return [];
        }

        return array_values(array_filter(
            $bidang,
            fn ($item): bool => is_string($item) && trim($item) !== ''
        ));
    }

    /** @param array<string, mixed> $hasil */
    private function catat(User $user, string $prompt, array $hasil, string $status): void
    {
        DB::table('ai_plans')->insert([
            'user_id' => $user->id,
            'prompt' => $prompt,
            'hasil' => json_encode($hasil),
            'status' => $status,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function tarikJson(string $teks): ?array
    {
        $teks = trim($teks);

        if (preg_match('/```(?:json)?\s*(.*?)```/s', $teks, $m) === 1) {
            $teks = trim($m[1]);
        }

        $awal = strpos($teks, '{');
        $akhir = strrpos($teks, '}');
        if ($awal === false || $akhir === false || $akhir <= $awal) {
            return null;
        }

        $potongan = substr($teks, $awal, $akhir - $awal + 1);

        try {
            $decod = json_decode($potongan, true, 512, JSON_THROW_ON_ERROR);
        } catch (\Throwable) {
            return null;
        }

        return is_array($decod) ? $decod : null;
    }
}
