<?php

namespace App\Http\Requests;

use App\Models\Course;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/**
 * @property string $nama
 * @property int $warna_index
 * @property int $ikon
 */
final class StoreCourseRequest extends FormRequest
{
    /** @return array<string, array<int, string>|string> */
    public function rules(): array
    {
        return [
            'nama' => ['required', 'string', 'max:100'],
            'warna_index' => ['sometimes', 'integer', 'between:0,7'],
            'ikon' => ['sometimes', 'integer', 'min:0'],
        ];
    }

    /** @return array<string, mixed> */
    public function validatedPayload(): array
    {
        return [
            'nama' => $this->input('nama'),
            'warna_index' => $this->integer('warna_index') ?? 0,
            'ikon' => $this->integer('ikon') ?? 0xe800,
        ];
    }
}
