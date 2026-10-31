<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Carbon;

/** Keluaran statistik mingguan. */
final class WeeklyStatsResource extends JsonResource
{
    /**
     * @param  \App\Http\StatsData&mixed  $resource
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'mulai' => $this->resource['mulai'],
            'sampai' => $this->resource['sampai'],
            'total_menit' => $this->resource['total_menit'],
            'per_hari' => $this->resource['per_hari'],
            'tugas_selesai' => $this->resource['tugas_selesai'],
            'streak' => $this->resource['streak'],
        ];
    }
}
