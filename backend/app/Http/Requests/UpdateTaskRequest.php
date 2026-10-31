<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/**
 * @property int|null $course_id
 * @property string|null $judul
 * @property string|null $catatan
 * @property string|null $tenggat
 * @property int|null $estimasi_menit
 * @property string|null $prioritas
 * @property string|null $status
 */
final class UpdateTaskRequest extends FormRequest
{
    /** @return array<string, array<int, mixed>|Rule|array<mixed>|string> */
    public function rules(): array
    {
        return [
            'course_id' => ['sometimes', 'required', 'integer'],
            'judul' => ['sometimes', 'required', 'string', 'max:200'],
            'catatan' => ['sometimes', 'nullable', 'string', 'max:2000'],
            'tenggat' => ['sometimes', 'required', 'date'],
            'estimasi_menit' => ['sometimes', 'required', 'integer', 'min:5', 'max:1440'],
            'prioritas' => ['sometimes', 'required', Rule::in(['tinggi', 'sedang', 'rendah'])],
            'status' => ['sometimes', 'required', Rule::in(['belum', 'berjalan', 'selesai'])],
        ];
    }
}
