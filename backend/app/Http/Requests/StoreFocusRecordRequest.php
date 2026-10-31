<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/**
 * @property int|null $task_id
 * @property string $mulai
 * @property int $durasi_menit
 */
final class StoreFocusRecordRequest extends FormRequest
{
    /** @return array<string, array<int, mixed>|Rule|array<mixed>|string> */
    public function rules(): array
    {
        return [
            'task_id' => ['nullable', 'integer'],
            'mulai' => ['required', 'date'],
            'durasi_menit' => ['required', 'integer', 'min:1', 'max:1440'],
        ];
    }

    /** @return \Illuminate\Validation\Validator */
    public function withValidator(\Illuminate\Validation\Validator $validator): void
    {
        $validator->after(function (\Illuminate\Validation\Validator $v) {
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
