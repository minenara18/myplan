<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreSessionRequest;
use App\Http\Requests\StoreSessionsBulkRequest;
use App\Http\Resources\StudySessionResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;

final class StudySessionController extends Controller
{
    /** GET /api/sessions?course_id=...&mulai=...&sampai=... */
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = $request->user()->studySessions()->orderBy('mulai');

        if ($request->filled('course_id')) {
            $query->where('course_id', $request->integer('course_id'));
        }
        if ($request->filled('mulai')) {
            $query->where('mulai', '>=', $request->date('mulai'));
        }
        if ($request->filled('sampai')) {
            $query->where('mulai', '<=', $request->date('sampai')->endOfDay());
        }

        return StudySessionResource::collection($query->get());
    }

    /** POST /api/sessions */
    public function store(StoreSessionRequest $request): JsonResponse
    {
        $session = $request->user()->studySessions()->create($request->validated());

        return StudySessionResource::make($session)->response()->setStatusCode(201);
    }

    /** POST /api/sessions/bulk — simpan banyak sesi sekaligus dalam satu transaksi. */
    public function storeBulk(StoreSessionsBulkRequest $request): JsonResponse
    {
        $dibuat = [];

        DB::transaction(function () use ($request, &$dibuat): void {
            foreach ($request->validated('sesi') as $item) {
                $dibuat[] = $request->user()->studySessions()->create($item);
            }
        });

        return response()->json(
            ['data' => StudySessionResource::collection(collect($dibuat))->resolve()],
            201,
        );
    }

    /** GET /api/sessions/{session} */
    public function show(Request $request, int $sessionId): StudySessionResource
    {
        $session = $request->user()->studySessions()->findOrFail($sessionId);
        $this->authorize('view', $session);

        return new StudySessionResource($session);
    }

    /** PUT/PATCH /api/sessions/{session} */
    public function update(Request $request, int $sessionId): StudySessionResource
    {
        $session = $request->user()->studySessions()->findOrFail($sessionId);
        $this->authorize('update', $session);

        $validated = $request->validate([
            'course_id' => ['sometimes', 'required', 'integer'],
            'task_id' => ['sometimes', 'nullable', 'integer'],
            'mulai' => ['sometimes', 'required', 'date'],
            'selesai' => ['sometimes', 'required', 'date'],
            'sumber' => ['sometimes', 'required', 'in:manual,ai'],
        ]);

        $session->update($validated);

        return new StudySessionResource($session->refresh());
    }

    /** DELETE /api/sessions/{session} */
    public function destroy(Request $request, int $sessionId): Response
    {
        $session = $request->user()->studySessions()->findOrFail($sessionId);
        $this->authorize('delete', $session);

        $session->delete();

        return response()->noContent();
    }
}
