<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\AiException;
use App\Http\Controllers\Controller;
use App\Http\Requests\PlanRequest;
use App\Services\Ai\AiPlanner;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Carbon;

final class AiPlanController extends Controller
{
    public function __construct(private readonly AiPlanner $planner) {}

    /** POST /api/ai/plan */
    public function store(PlanRequest $request): JsonResponse
    {
        $user = $request->user();

        try {
            $hasil = $this->planner->susun(
                $user,
                $request->carbon('mulai') ?? Carbon::now(),
                $request->carbon('sampai') ?? Carbon::now(),
                $request->jamMulai(),
                $request->jamSelesai(),
                // course_id => nama mata kuliah, konteks saja untuk prompt.
                $user->courses()->pluck('nama', 'id')->all(),
            );
        } catch (AiException) {
            return response()->json([
                'message' => 'Penyusun AI gagal dan fallback juga kosong.',
                'errors' => [],
                'code' => 'AI_GAGAL',
            ], 502);
        }

        return response()->json(['data' => $hasil]);
    }
}
