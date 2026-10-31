<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

final class StatsController extends Controller
{
    /**
     * GET /api/stats/weekly?mulai=YYYY-MM-DD
     * Total menit, per hari, tugas selesai, dan streak milik pengguna.
     */
    public function weekly(Request $request): JsonResponse
    {
        $user = $request->user();

        $mulai = $request->filled('mulai') && strtotime((string) $request->input('mulai')) !== false
            ? Carbon::parse((string) $request->input('mulai'))->startOfDay()
            : now()->startOfWeek();

        $sampai = (clone $mulai)->addDays(6)->endOfDay();

        $records = $user->focusRecords()
            ->whereBetween('mulai', [$mulai, $sampai])
            ->get();

        $perHari = [];
        $totalMenit = 0;
        for ($i = 0; $i < 7; $i++) {
            $hari = (clone $mulai)->addDays($i);
            $menit = $records
                ->where('mulai', '>=', $hari->copy()->startOfDay())
                ->where('mulai', '<', $hari->copy()->addDay()->startOfDay())
                ->sum('durasi_menit');
            $perHari[] = [
                'tanggal' => $hari->toDateString(),
                'menit' => (int) $menit,
            ];
            $totalMenit += (int) $menit;
        }

        $tugasSelesai = $user->tasks()
            ->where('status', 'selesai')
            ->whereBetween('updated_at', [$mulai, $sampai])
            ->count();

        $streak = $this->hitungStreak($user->focusRecords()->get());

        return response()->json([
            'data' => [
                'mulai' => $mulai->toDateString(),
                'sampai' => $sampai->toDateString(),
                'total_menit' => $totalMenit,
                'per_hari' => $perHari,
                'tugas_selesai' => $tugasSelesai,
                'streak' => $streak,
            ],
        ]);
    }

    /** Hitung runtutan hari terdepan yang punya rekaman fokus. */
    private function hitungStreak($records): int // @phpstan-ignore missingType.iterableValue
    {
        $tanggal = $records
            ->map(fn ($r) => Carbon::parse($r->mulai)->startOfDay())
            ->reverse()
            ->unique()
            ->values();

        if ($tanggal->isEmpty()) {
            return 0;
        }

        $streak = 1;
        foreach ($tanggal as $i => $t) {
            if ($i === 0) {
                $prev = $t;
                continue;
            }
            if ($prev->diffInDays($t) === 1) {
                $streak++;
                $prev = $t;
            } else {
                break;
            }
        }

        return $streak;
    }
}
