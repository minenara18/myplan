<?php

namespace App\Http\Requests;

use App\Models\Course;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/**
 * @property int $course_id
 * @property int|null $task_id
 * @property string $mulai
 * @property string $selesai
 * @property string $sumber
 */
final class StoreSessionRequest extends FormRequest
{
    /** @return array<string, array<int, mixed>|Rule|array<mixed>|string> */
    public function rules(): array
    {
        return [
            'course_id' => ['required', 'integer'],
            'task_id' => ['nullable', 'integer'],
            'mulai' => ['required', 'date'],
            'selesai' => ['required', 'date', 'after:mulai'],
            'sumber' => ['required', Rule::in(['manual', 'ai'])],
        ];
    }

    /** @return \Illuminate\Validation\Validator */
    public function withValidator(\Illuminate\Validation\Validator $validator): void
    {
        $validator->after(function (\Illuminate\Validation\Validator $v) {
            $course = Course::find($this->integer('course_id'));
            if ($course === null ||
                $course->user_id !== $this->user()->id) {
                $v->errors()->add('course_id', 'Mata kuliah tidak ada atau bukan milik Anda.');
            }

            $taskId = $this->input('task_id');
            if ($taskId !== null) {
                $task = $this->user()->tasks()->find($taskId);
                if ($task === null) {
                    $v->errors()->add('task_id', 'Tugas tidak ada atau bukan milik Anda.');
                }
            }
        });
    }
}
