<?php

namespace App\Http\Requests;

use App\Models\Course;
use App\Models\User;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/**
 * @property int $course_id
 * @property string $judul
 * @property string|null $catatan
 * @property string $tenggat
 * @property int $estimasi_menit
 * @property string $prioritas
 * @property string $status
 */
final class StoreTaskRequest extends FormRequest
{
    /** @return array<string, array<int, string>|Rule|array<mixed>|string> */
    public function rules(): array
    {
        return [
            'course_id' => ['required', 'integer'],
            'judul' => ['required', 'string', 'max:200'],
            'catatan' => ['nullable', 'string', 'max:2000'],
            'tenggat' => ['required', 'date'],
            'estimasi_menit' => ['required', 'integer', 'min:5', 'max:1440'],
            'prioritas' => ['required', Rule::in(['tinggi', 'sedang', 'rendah'])],
            'status' => ['required', Rule::in(['belum', 'berjalan', 'selesai'])],
        ];
    }

    /** Konfirmasi course_id milik pengguna ini. */
    public function courseBelongsToUser(): bool
    {
        $course = Course::find($this->integer('course_id'));

        return $course !== null && $course->user_id === $this->user()->id;
    }

    /** @return array{with:array<string, string>} */
    public function withValidator(\Illuminate\Validation\Validator $validator): void
    {
        $validator->after(function (\Illuminate\Validation\Validator $validator) {
            if (! $this->courseBelongsToUser()) {
                $validator->errors()->add(
                    'course_id',
                    'Mata kuliah tidak ada atau bukan milik Anda.'
                );
            }
        });
    }
}
