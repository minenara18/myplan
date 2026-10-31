<?php

namespace App\Http\Requests;

use App\Models\Course;
use Illuminate\Foundation\Http\FormRequest;

/**
 * @property string|null $nama
 * @property int|null $warna_index
 * @property int|null $ikon
 */
final class UpdateCourseRequest extends FormRequest
{
    /** @return array<string, array<int, string>|string> */
    public function rules(): array
    {
        return [
            'nama' => ['sometimes', 'required', 'string', 'max:100'],
            'warna_index' => ['sometimes', 'integer', 'between:0,7'],
            'ikon' => ['sometimes', 'integer', 'min:0'],
        ];
    }
}
