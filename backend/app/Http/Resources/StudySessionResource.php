<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\StudySession */
final class StudySessionResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'task_id' => $this->task_id,
            'course_id' => $this->course_id,
            'mulai' => $this->mulai->toIso8601String(),
            'selesai' => $this->selesai->toIso8601String(),
            'sumber' => $this->sumber,
        ];
    }
}
