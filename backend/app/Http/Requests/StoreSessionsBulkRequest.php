<?php

namespace App\Http\Requests;

use App\Models\Course;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\DB;

/**
 * @property array<int, array{course_id: int, task_id?: int|null, mulai: string, selesai: string, sumber: string}> $sesi
 */
final class StoreSessionsBulkRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /** @return array<string, array<int, mixed>|string> */
    public function rules(): array
    {
        return [
            'sesi' => ['required', 'array', 'min:1', 'max:50'],
            'sesi.*.course_id' => ['required', 'integer'],
            'sesi.*.task_id' => ['nullable', 'integer'],
            'sesi.*.mulai' => ['required', 'date'],
            'sesi.*.selesai' => ['required', 'date', 'after:sesi.*.mulai'],
            'sesi.*.sumber' => ['required', 'in:manual,ai'],
        ];
    }

    /**
     * Semua sesi harus milik pengguna — mata kuliah dan tugas dicek satu per satu.
     * Kegagalan validasi ditempatkan pada field asal agar aplikasi bisa menandai blok.
     */
    public function withValidator(\Illuminate\Validation\Validator $validator): void
    {
        $validator->after(function (\Illuminate\Validation\Validator $v): void {
            $sesi = $this->input('sesi');

            if (! is_array($sesi)) {
                return;
            }

            $courseIds = [];
            $taskIds = [];
            foreach ($sesi as $item) {
                if (is_array($item)) {
                    $courseIds[] = $item['course_id'] ?? null;
                    if (($item['task_id'] ?? null) !== null) {
                        $taskIds[] = $item['task_id'];
                    }
                }
            }

            $mataKuliahSah = DB::table('courses')
                ->where('user_id', $this->user()->id)
                ->whereIn('id', array_values(array_unique(array_filter($courseIds))))
                ->pluck('id')
                ->all();
            $tugasSah = DB::table('tasks')
                ->where('user_id', $this->user()->id)
                ->whereIn('id', array_values(array_unique(array_filter($taskIds))))
                ->pluck('id')
                ->all();

            foreach ($sesi as $i => $item) {
                if (! is_array($item)) {
                    continue;
                }
                if (! in_array($item['course_id'] ?? 0, $mataKuliahSah, true)) {
                    $v->errors()->add("sesi.$i.course_id", 'Mata kuliah tidak ada atau bukan milik Anda.');
                }
                $taskId = $item['task_id'] ?? null;
                if ($taskId !== null && ! in_array($taskId, $tugasSah, true)) {
                    $v->errors()->add("sesi.$i.task_id", 'Tugas tidak ada atau bukan milik Anda.');
                }
            }
        });
    }
}
