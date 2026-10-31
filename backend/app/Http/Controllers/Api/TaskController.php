<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreTaskRequest;
use App\Http\Requests\UpdateTaskRequest;
use App\Http\Resources\TaskResource;
use App\Models\Task;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;

final class TaskController extends Controller
{
    /** GET /api/tasks?course_id=... */
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = $request->user()->tasks()->orderBy('tenggat');

        if ($request->filled('course_id')) {
            $query->where('course_id', $request->integer('course_id'));
        }

        return TaskResource::collection($query->get());
    }

    /** POST /api/tasks */
    public function store(StoreTaskRequest $request): JsonResponse
    {
        $task = $request->user()->tasks()->create($request->validated());

        return TaskResource::make($task->load('course'))->response()->setStatusCode(201);
    }

    /** GET /api/tasks/{task} */
    public function show(Request $request, int $taskId): TaskResource
    {
        $task = $request->user()->tasks()->findOrFail($taskId);
        $this->authorize('view', $task);

        return new TaskResource($task);
    }

    /** PUT/PATCH /api/tasks/{task} */
    public function update(UpdateTaskRequest $request, int $taskId): TaskResource
    {
        $task = $request->user()->tasks()->findOrFail($taskId);
        $this->authorize('update', $task);

        $task->update($request->validated());

        return new TaskResource($task->refresh());
    }

    /** DELETE /api/tasks/{task} */
    public function destroy(Request $request, int $taskId): Response
    {
        $task = $request->user()->tasks()->findOrFail($taskId);
        $this->authorize('delete', $task);

        $task->delete();

        return response()->noContent();
    }
}
