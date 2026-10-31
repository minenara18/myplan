<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** Keluaran pengaturan per pengguna. */
final class SettingsResource extends JsonResource
{
    /**
     * @param  \App\Models\User  $resource
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $settings = $resource->settings ?? [];

        return [
            'reminder_enabled' => $settings['reminder_enabled'] ?? true,
            'default_pomodoro_minutes' => $settings['default_pomodoro_minutes'] ?? 25,
            'daily_free_time_start' => $settings['daily_free_time_start'] ?? 16,
            'daily_free_time_end' => $settings['daily_free_time_end'] ?? 21,
        ];
    }
}
