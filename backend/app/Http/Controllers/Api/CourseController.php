<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCourseRequest;
use App\Http\Requests\UpdateCourseRequest;
use App\Http\Resources\CourseResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;

final class CourseController extends Controller
{
    /** GET /api/courses */
    public function index(Request $request): AnonymousResourceCollection
    {
        $courses = $request->user()->courses()
            ->orderBy('created_at')
            ->get();

        return CourseResource::collection($courses);
    }

    /** POST /api/courses */
    public function store(StoreCourseRequest $request): JsonResponse
    {
        $course = $request->user()->courses()->create($request->validatedPayload());

        return CourseResource::make($course)->response()->setStatusCode(201);
    }

    /** GET /api/courses/{course} */
    public function show(Request $request, int $courseId): CourseResource
    {
        $course = $request->user()->courses()->findOrFail($courseId);
        $this->authorize('view', $course);

        return new CourseResource($course);
    }

    /** PUT/PATCH /api/courses/{course} */
    public function update(UpdateCourseRequest $request, int $courseId): CourseResource
    {
        $course = $request->user()->courses()->findOrFail($courseId);
        $this->authorize('update', $course);

        $course->update(array_filter($request->validated(), fn ($v) => $v !== null));

        return new CourseResource($course->refresh());
    }

    /** DELETE /api/courses/{course} */
    public function destroy(Request $request, int $courseId): Response
    {
        $course = $request->user()->courses()->findOrFail($courseId);
        $this->authorize('delete', $course);

        $course->delete();

        return response()->noContent();
    }
}
