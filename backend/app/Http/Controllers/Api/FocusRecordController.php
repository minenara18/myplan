<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreFocusRecordRequest;
use App\Http\Resources\FocusRecordResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;

final class FocusRecordController extends Controller
{
    /** GET /api/focus-records?mulai=...&sampai=... */
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = $request->user()->focusRecords()->orderBy('mulai', 'desc');

        if ($request->filled('mulai')) {
            $query->where('mulai', '>=', $request->date('mulai'));
        }
        if ($request->filled('sampai')) {
            $query->where('mulai', '<=', $request->date('sampai')->endOfDay());
        }

        return FocusRecordResource::collection($query->get());
    }

    /** POST /api/focus-records */
    public function store(StoreFocusRecordRequest $request): JsonResponse
    {
        $record = $request->user()->focusRecords()->create($request->validated());

        return FocusRecordResource::make($record)->response()->setStatusCode(201);
    }

    /** DELETE /api/focus-records/{record} */
    public function destroy(Request $request, int $recordId): Response
    {
        $record = $request->user()->focusRecords()->findOrFail($recordId);
        $this->authorize('delete', $record);

        $record->delete();

        return response()->noContent();
    }
}
