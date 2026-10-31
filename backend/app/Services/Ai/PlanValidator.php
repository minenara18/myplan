<?php

namespace App\Services\Ai;

use Illuminate\Support\Carbon;

/**
 * Validator entri jadwal dari LLM. Blok yang tidak lolos dibuang
 * secara diam-diam — server adalah sumber kebenaran.
 */
final class PlanValidator
{
    /**
     * @param  array<int, mixed>  $blok  entri mentah dari LLM
     * @param  array<string, array<string, mixed>>  $tugasSah  task_id => tugas (tenggat Carbon)
     * @param  array<int, array<string, mixed>>  $sesiAda  mulai(Carbon), selesai(Carbon)
     * @param  array<int, array<string, mixed>>  $blokDisimpan  blok valid lain yang dihitung juga
     * @return array<int, array{task_id: mixed, mulai: Carbon, selesai: Carbon, alasan: string}>
     */
    public function saring(
        array $blok,
        array $tugasSah,
        array $sesiAda,
        Carbon $rentangMulai,
        Carbon $rentangSampai,
        int $jamMulai,
        int $jamSelesai,
        ?Carbon $sekarang = null,
    ): array {
        $sekarang ??= Carbon::now();
        $lolos = [];

        foreach ($blok as $entri) {
            if (! is_array($entri)) {
                continue;
            }

            $taskId = $entri['task_id'] ?? null;
            if (! is_string($taskId) && ! is_int($taskId)) {
                continue;
            }
            $taskId = (string) $taskId;
            if (! isset($tugasSah[$taskId])) {
                continue;
            }

            $mulai = $this->parseWaktu($entri['mulai'] ?? null);
            $selesai = $this->parseWaktu($entri['selesai'] ?? null);
            if ($mulai === null || $selesai === null || $selesai->lte($mulai)) {
                continue;
            }

            // Di dalam rentang yang diminta, dan tidak di masa lalu.
            if ($mulai->lt($rentangMulai->startOfDay()) ||
                $selesai->gt($rentangSampai->endOfDay()) ||
                $selesai->lt($sekarang)
            ) {
                continue;
            }

            // Boleh tetap: blok sesuai waktu luang harian.
            if (! $this->dalamWaktuLuang($mulai, $selesai, $jamMulai, $jamSelesai)) {
                continue;
            }

            // Tidak melebihi tenggat tugasnya.
            $tenggat = $tugasSah[$taskId]['tenggat'];
            if ($tenggat instanceof Carbon && $selesai->gt($tenggat)) {
                continue;
            }

            // Tidak menimpa sesi yang sudah ada maupun blok valid lain.
            $semua = array_merge($sesiAda, $lolos);
            $mengenai = $this->bentrok($mulai, $selesai, $semua);
            if ($mengenai) {
                continue;
            }

            $alasan = $entri['alasan'] ?? null;
            if (! is_string($alasan) || trim($alasan) === '') {
                $alasan = 'Disusun AI untuk '.$tugasSah[$taskId]['judul'].'.';
            }
            // Satu kalimat saja.
            $alasan = trim(preg_split('/\r\n|\r|\n/', trim($alasan))[0] ?? '');
            if (mb_strlen($alasan) > 200) {
                $alasan = mb_substr($alasan, 0, 200);
            }

            $lolos[] = [
                'task_id' => $taskId,
                'mulai' => $mulai,
                'selesai' => $selesai,
                'alasan' => $alasan,
            ];
        }

        return $lolos;
    }

    /**
     * @param  array<int, array<string, mixed>>  $semuaBlok
     */
    private function bentrok(Carbon $mulai, Carbon $selesai, array $semuaBlok): bool
    {
        foreach ($semuaBlok as $b) {
            if ($mulai->lt($b['selesai']) && $b['mulai']->lt($selesai)) {
                return true;
            }
        }

        return false;
    }

    private function dalamWaktuLuang(Carbon $mulai, Carbon $selesai, int $jamMulai, int $jamSelesai): bool
    {
        $hari = $mulai->copy()->startOfDay();
        $jendelaMulai = $hari->copy()->addHours($jamMulai);
        $jendelaSelesai = $hari->copy()->addHours($jamSelesai);

        return $mulai->gte($jendelaMulai) && $selesai->lte($jendelaSelesai)
            // Blok yang melewati tengah malam tidak sah — harus satu hari.
            && $mulai->isSameDay($selesai);
    }

    private function parseWaktu(mixed $nilai): ?Carbon
    {
        if (! is_string($nilai) && ! is_int($nilai)) {
            return null;
        }
        try {
            return Carbon::parse((string) $nilai);
        } catch (\Throwable) {
            return null;
        }
    }
}
