<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Task */
final class TaskResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'course_id' => $this->course_id,
            'judul' => $this->judul,
            'catatan' => $this->catatan,
            'tenggat' => $this->tenggat->toIso8601String(),
            'estimasi_menit' => $this->estimasi_menit,
            'prioritas' => $this->prioritas,
            'status' => $this->status,
        ];
    }
}
