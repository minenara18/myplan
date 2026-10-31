<?php

namespace App\Services\Ai;

use Illuminate\Support\Carbon;

/**
 * Penjadwal fallback ketika LLM gagal: tugas dengan tenggat terdekat
 * disusun lebih dulu ke jendela waktu luang harian, melewati sesi yang
 * sudah ada. Dipakai agar demo tidak pernah kosong.
 */
final class DeterministicPlanner
{
    /** Peringkat prioritas: lebih kecil = lebih penting. */
    private const RANK_PRIORITAS = ['tinggi' => 0, 'sedang' => 1, 'rendah' => 2];

    /** Panjang satu blok belajar (menit). */
    private const BLOK_MENIT = 60;

    /**
     * @param  array<int, array<string, mixed>>  $tugas     id, judul, tenggat(Carbon), estimasi_menit, prioritas
     * @param  array<int, array<string, mixed>>  $sesiAda   mulai(Carbon), selesai(Carbon)
     * @return array<int, array<string, mixed>>  blok-blok {task_id, mulai, selesai, alasan}
     */
    public function susun(
        array $tugas,
        array $sesiAda,
        Carbon $rentangMulai,
        Carbon $rentangSampai,
        int $jamMulai,
        int $jamSelesai,
        ?Carbon $sekarang = null,
    ): array {
        $sekarang ??= Carbon::now();
        $tuntas = [];

        foreach ($this->urutkan($tugas) as $tugasData) {
            $sisa = max(1, (int) $tugasData['estimasi_menit']);
            $hari = $rentangMulai->copy()->startOfDay();
            $batasHari = $rentangSampai->copy()->startOfDay();

            while ($sisa > 0 && $hari->lessThanOrEqualTo($batasHari)) {
                // Tenggat sudah terlewati — tugas ini tidak bisa dijadwalkan lagi.
                $tenggat = $tugasData['tenggat'] instanceof Carbon ? $tugasData['tenggat'] : null;
                if ($tenggat !== null && $tenggat->startOfDay()->endOfDay()->lt($sekarang)) {
                    break;
                }

                $jendelaMulai = $hari->copy()->addHours($jamMulai);
                if ($jendelaMulai->lt($sekarang)) {
                    $jendelaMulai = $sekarang->copy();
                }
                $jendelaSelesai = $hari->copy()->addHours($jamSelesai);

                if ($jendelaSelesai->lte($jendelaMulai)) {
                    $hari->addDay();

                    continue;
                }

                $potongan = min(self::BLOK_MENIT, $sisa);
                $slot = $this->cariSlot($tuntas, $sesiAda, $jendelaMulai, $jendelaSelesai, $potongan, $sekarang);

                if ($slot === null) {
                    $hari->addDay();

                    continue;
                }

                // Truncasi bila blok melewati tenggat.
                if ($tenggat !== null && $slot['selesai']->gt($tenggat)) {
                    $slot['selesai'] = $tenggat->copy();
                    if ($slot['selesai']->lessThanOrEqualTo($slot['mulai'])) {
                        $hari->addDay();

                        continue;
                    }
                    $sisa = 0;
                } else {
                    $sisa -= $potongan;
                }

                $tuntas[] = [
                    'task_id' => $tugasData['id'],
                    'mulai' => $slot['mulai'],
                    'selesai' => $slot['selesai'],
                    'alasan' => 'Tenggat terdekat diutamakan: '.$tugasData['judul'].'.',
                ];
            }
        }

        return $tuntas;
    }

    /**
     * Urutkan tugas: tenggat terdekat dulu; selisih tenggat kecil menanjakan prioritas.
     *
     * @param  array<int, array<string, mixed>>  $tugas
     * @return array<int, array<string, mixed>>
     */
    private function urutkan(array $tugas): array
    {
        usort($tugas, function ($a, $b): int {
            $tenggatA = $a['tenggat'] instanceof Carbon ? $a['tenggat']->getTimestamp() : 0;
            $tenggatB = $b['tenggat'] instanceof Carbon ? $b['tenggat']->getTimestamp() : 0;

            if ($tenggatA !== $tenggatB) {
                return $tenggatA <=> $tenggatB;
            }

            return
                (self::RANK_PRIORITAS[$a['prioritas']] ?? 1)
                <=> (self::RANK_PRIORITAS[$b['prioritas']] ?? 1);
        });

        return $tugas;
    }

    /**
     * Cari rentang bebas di [mulaiT, selesaiT] yang memuat potongan menit tanpa tabrakan.
     *
     * @param  array<int, array<string, mixed>>  $tuntas
     * @param  array<int, array<string, mixed>>  $sesiAda
     * @return array{mulai: Carbon, selesai: Carbon}|null
     */
    private function cariSlot(
        array $tuntas,
        array $sesiAda,
        Carbon $mulaiT,
        Carbon $selesaiT,
        int $potongan,
        Carbon $sekarang,
    ): ?array {
        $kandidat = $mulaiT->copy();

        while (true) {
            $akhir = $kandidat->copy()->addMinutes($potongan);

            if ($akhir->gt($selesaiT)) {
                return null;
            }

            $semua = array_merge($sesiAda, $tuntas);
            $tabrakanTerdekat = null;

            foreach ($semua as $b) {
                if ($this->bentrok($kandidat, $akhir, $b['mulai'], $b['selesai'])) {
                    $tabrakanTerdekat = $b['selesai'];

                    break;
                }
            }

            if ($tabrakanTerdekat === null && $akhir->gt($sekarang)) {
                return ['mulai' => $kandidat->copy(), 'selesai' => $akhir];
            }

            $kandidat = $tabrakanTerdekat !== null
                ? $tabrakanTerdekat->copy()
                : $akhir;
        }
    }

    private function bentrok(Carbon $aMulai, Carbon $aSelesai, Carbon $bMulai, Carbon $bSelesai): bool
    {
        return $aMulai->lt($bSelesai) && $bMulai->lt($aSelesai);
    }
}
