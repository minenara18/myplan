<?php

namespace App\Services\Ai;

use App\Contracts\AiProvider;
use App\Exceptions\AiException;
use App\Models\StudySession;
use App\Models\Task;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

/**
 * Menyusun rencana belajar: prompt dibangun server, LLM mengusulkan blok,
 * server memvalidasi ketat, dan jatuh ke penjadwal deterministik bila LLM gagal.
 * Semua hasil — sukses maupun gagal — dicatat ke tabel ai_plans.
 */
final class AiPlanner
{
    public function __construct(
        private readonly AiProvider $provider,
        private readonly PlanValidator $validator,
        private readonly DeterministicPlanner $planner,
    ) {}

    /**
     * @param  array<int, string>  $mataKuliahNama  course_id => nama
     * @return array{sesi: array<int, array<string, mixed>>, prioritas: array<int, string>, sumber: string}
     */
    public function susun(
        User $user,
        Carbon $rentangMulai,
        Carbon $rentangSampai,
        int $jamMulai,
        int $jamSelesai,
        array $mataKuliahNama = [],
    ): array {
        $proyek = $this->proyek($user, $rentangMulai, $rentangSampai, $jamMulai, $jamSelesai, $mataKuliahNama);

        [$blok, $sumber, $berhasil] = $this->cobaLlm(
            $this->provider, $proyek, $user, $rentangMulai, $rentangSampai, $jamMulai, $jamSelesai,
        );

        $hasil = [
            'sumber' => $sumber,
            'rentang' => [
                'mulai' => $rentangMulai->toDateString(),
                'sampai' => $rentangSampai->toDateString(),
            ],
            'sesi' => $blok,
            'prioritas' => $this->urutPrioritas($blok),
        ];

        DB::table('ai_plans')->insert([
            'user_id' => $user->id,
            'prompt' => $proyek['prompt_user'],
            'hasil' => json_encode($hasil),
            'status' => $berhasil ? 'selesai' : 'gagal',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $hasil;
    }

    /**
     * @param  array{prompt_sistem: string, prompt_user: string}  $proyek
     * @return array{0: array<int, array<string, mixed>>, 1: string, 2: bool}
     */
    private function cobaLlm(
        AiProvider $provider,
        array $proyek,
        User $user,
        Carbon $rentangMulai,
        Carbon $rentangSampai,
        int $jamMulai,
        int $jamSelesai,
    ): array {
        try {
            $jawaban = $provider->selesaikan($proyek['prompt_sistem'], $proyek['prompt_user']);
            $json = $this->tarikJson($jawaban);
        } catch (AiException) {
            return [$this->fallback($user, $rentangMulai, $rentangSampai, $jamMulai, $jamSelesai), 'fallback', false];
        }

        if ($json === null || ! isset($json['sesi']) || ! is_array($json['sesi'])) {
            return [$this->fallback($user, $rentangMulai, $rentangSampai, $jamMulai, $jamSelesai), 'fallback', false];
        }

        $tugasSah = $this->tugasSahMap($user);
        $sesiAda = $this->sesiAda($user, $rentangMulai, $rentangSampai);
        $lolos = $this->validator->saring(
            $json['sesi'],
            $tugasSah,
            $sesiAda,
            $rentangMulai,
            $rentangSampai,
            $jamMulai,
            $jamSelesai,
        );

        if ($lolos === []) {
            return [$this->fallback($user, $rentangMulai, $rentangSampai, $jamMulai, $jamSelesai), 'fallback', false];
        }

        $blok = array_map(
            fn (array $b): array => [
                'task_id' => $b['task_id'],
                'mulai' => $b['mulai']->toIso8601String(),
                'selesai' => $b['selesai']->toIso8601String(),
                'alasan' => $b['alasan'],
            ],
            $lolos,
        );

        return [$blok, 'ai', true];
    }

    /** @return array<int, array<string, mixed>> blok siap serialisasi */
    private function fallback(
        User $user,
        Carbon $rentangMulai,
        Carbon $rentangSampai,
        int $jamMulai,
        int $jamSelesai,
    ): array {
        $tugas = [];
        foreach ($user->tasks()->whereIn('status', ['belum', 'berjalan'])->get() as $tugasModel) {
            /** @var Task $tugasModel */
            $tugas[] = [
                'id' => (string) $tugasModel->id,
                'judul' => $tugasModel->judul,
                'tenggat' => $tugasModel->tenggat,
                'estimasi_menit' => $tugasModel->estimasi_menit,
                'prioritas' => $tugasModel->prioritas,
            ];
        }
        $sesiAda = $this->sesiAda($user, $rentangMulai, $rentangSampai);

        return array_map(
            fn (array $b): array => [
                'task_id' => (string) $b['task_id'],
                'mulai' => $b['mulai']->toIso8601String(),
                'selesai' => $b['selesai']->toIso8601String(),
                'alasan' => (string) $b['alasan'],
            ],
            $this->planner->susun($tugas, $sesiAda, $rentangMulai, $rentangSampai, $jamMulai, $jamSelesai),
        );
    }

    /**
     * Bangun prompt sistem dan isi pengguna (konteks tugas, waktu luang,
     * sesi yang sudah ada).
     *
     * @param  array<int, string>  $mataKuliahNama
     * @return array{prompt_sistem: string, prompt_user: string}
     */
    private function proyek(
        User $user,
        Carbon $rentangMulai,
        Carbon $rentangSampai,
        int $jamMulai,
        int $jamSelesai,
        array $mataKuliahNama,
    ): array {
        $tugas = [];
        foreach ($user->tasks()->whereIn('status', ['belum', 'berjalan'])->with('course')->get() as $tugasModel) {
            /** @var Task $tugasModel */
            $tugas[] = [
                'task_id' => (string) $tugasModel->id,
                'judul' => $tugasModel->judul,
                'mata_kuliah' => $mataKuliahNama[$tugasModel->course_id] ?? null,
                'tenggat' => $tugasModel->tenggat?->toIso8601String(),
                'estimasi_menit' => (int) $tugasModel->estimasi_menit,
                'prioritas' => $tugasModel->prioritas,
            ];
        }

        $sesiSudahAda = array_map(
            fn (StudySession $s): array => [
                'course_id' => (string) $s->course_id,
                'mulai' => $s->mulai->toIso8601String(),
                'selesai' => $s->selesai->toIso8601String(),
            ],
            $this->osesi($user, $rentangMulai, $rentangSampai),
        );

        $promptSistem = <<<'TEKS'
Kamu penjadwal belajar. Balas HANYA JSON tanpa penjelasan, dengan bentuk:
{
  "sesi": [
    {"task_id": "<id dari daftar>", "mulai": "ISO-8601", "selesai": "ISO-8601", "alasan": "<satu kalimat>"}
  ],
  "prioritas": ["<id tugas>", ...]
}
Aturan: jangan keluar dari daftar task_id; mulai < selesai; jangan menabrak sesi
yang sudah ada; blok di dalam waktu luang harian; selesai sebelum tenggat tugas.
TEKS;

        $promptUser = json_encode([
            'rentang_tanggal' => [
                'mulai' => $rentangMulai->toDateString(),
                'sampai' => $rentangSampai->toDateString(),
            ],
            'waktu_luang_harian' => ['jam_mulai' => $jamMulai, 'jam_selesai' => $jamSelesai],
            'daftar_tugas' => $tugas,
            'sesi_sudah_ada' => $sesiSudahAda,
        ], JSON_UNESCAPED_UNICODE);

        return [
            'prompt_sistem' => $promptSistem,
            'prompt_user' => $promptUser === false ? '{}' : $promptUser,
        ];
    }

    /** @return array<int, StudySession> */
    private function osesi(User $user, Carbon $rentangMulai, Carbon $rentangSampai): array
    {
        return $user->studySessions()
            ->whereBetween('mulai', [$rentangMulai->startOfDay(), $rentangSampai->endOfDay()])
            ->orderBy('mulai')
            ->get()
            ->all();
    }

    /** @return array<int, array{mulai: Carbon, selesai: Carbon}> */
    private function sesiAda(User $user, Carbon $rentangMulai, Carbon $rentangSampai): array
    {
        return array_map(
            fn (StudySession $s): array => [
                'mulai' => $s->mulai,
                'selesai' => $s->selesai,
            ],
            $this->osesi($user, $rentangMulai, $rentangSampai),
        );
    }

    /** @return array<string, array{judul: string, tenggat: ?Carbon}> */
    private function tugasSahMap(User $user): array
    {
        $peta = [];
        foreach ($user->tasks()->whereIn('status', ['belum', 'berjalan'])->get() as $tugasModel) {
            /** @var Task $tugasModel */
            $peta[(string) $tugasModel->id] = [
                'judul' => $tugasModel->judul,
                'tenggat' => $tugasModel->tenggat,
            ];
        }

        return $peta;
    }

    /** Urutan prioritas: id tugas mengikuti waktu mulai blok terawalnya. */
    /** @param array<int, array<string, mixed>> $blok @return array<int, string> */
    private function urutPrioritas(array $blok): array
    {
        usort(
            $blok,
            fn (array $a, array $b): int => Carbon::parse($a['mulai'])->getTimestamp()
                <=> Carbon::parse($b['mulai'])->getTimestamp(),
        );

        $urutan = [];
        foreach ($blok as $b) {
            $id = (string) $b['task_id'];
            if (! in_array($id, $urutan, true)) {
                $urutan[] = $id;
            }
        }

        return $urutan;
    }

    /** Pilih objek JSON dari teks jawaban LLM (bisa dibungkus blok kode). */
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
