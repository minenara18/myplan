<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * @property bool|null $reminder_enabled
 * @property int|null $default_pomodoro_minutes
 * @property int|null $daily_free_time_start
 * @property int|null $daily_free_time_end
 */
final class UpdateSettingsRequest extends FormRequest
{
    /** @return array<string, array<int, string>|string> */
    public function rules(): array
    {
        return [
            'reminder_enabled' => ['sometimes', 'required', 'boolean'],
            'default_pomodoro_minutes' => ['sometimes', 'required', 'integer', 'in:25,5,15'],
            'daily_free_time_start' => ['sometimes', 'required', 'integer', 'between:0,23'],
            'daily_free_time_end' => ['sometimes', 'required', 'integer', 'between:1,24'],
        ];
    }

    /**
     * @param  array<string, mixed>  $current
     * @return array<string, mixed>
     */
    public function mergedSettings(array $current): array
    {
        return array_merge($current, array_filter($this->validated()));
    }
}
