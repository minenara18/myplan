<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\AiException;
use App\Http\Controllers\Controller;
use App\Http\Requests\SummarizeRequest;
use App\Services\Ai\MateriSummarizer;
use Illuminate\Http\JsonResponse;

final class AiSummarizeController extends Controller
{
    public function __construct(private readonly MateriSummarizer $summarizer) {}

    /** POST /api/ai/summarize */
    public function store(SummarizeRequest $request): JsonResponse
    {
        try {
            $hasil = $this->summarizer->ringkas($request->user(), $request->teks());
        } catch (AiException $e) {
            return response()->json([
                'message' => 'Ringkasan AI gagal: '.$e->getMessage(),
                'errors' => [],
                'code' => 'AI_GAGAL',
            ], 502);
        }

        return response()->json(['data' => $hasil]);
    }
}
