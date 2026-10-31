<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Carbon;

/** Validasi permintaan penyusunan rencana AI. */
final class PlanRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /** @return array<string, array<int, string>> */
    public function rules(): array
    {
        return [
            'mulai' => ['required', 'date'],
            'sampai' => ['required', 'date', 'after_or_equal:mulai'],
            'jam_mulai' => ['sometimes', 'integer', 'between:0,22'],
            'jam_selesai' => ['sometimes', 'integer', 'between:1,24'],
        ];
    }

    /** Rentang jangan terlalu lebar agar LLM tidak menuntun 14 hari lebih. */
    public function withValidator(\Illuminate\Validation\Validator $validator): void
    {
        $validator->after(function (\Illuminate\Validation\Validator $v): void {
            $mulai = $this->carbon('mulai');
            $sampai = $this->carbon('sampai');

            if ($mulai !== null && $sampai !== null && $sampai->diffInDays($mulai) > 14) {
                $v->errors()->add('sampai', 'Rentang maksimal 14 hari.');
            }

            $jamMulai = $this->filled('jam_mulai') ? (int) $this->input('jam_mulai') : null;
            $jamSelesai = $this->filled('jam_selesai') ? (int) $this->input('jam_selesai') : null;
            if ($jamMulai !== null && $jamSelesai !== null && $jamMulai >= $jamSelesai) {
                $v->errors()->add('jam_selesai', 'jam_selesai harus lebih besar dari jam_mulai.');
            }
        });
    }

    public function carbon(string $field): ?Carbon
    {
        $nilai = $this->input($field);

        return is_string($nilai) ? Carbon::parse($nilai) : null;
    }

    /** @return int<0, 22> */
    public function jamMulai(): int
    {
        $nilai = $this->input('jam_mulai');

        return is_numeric($nilai) ? (int) $nilai : 16;
    }

    /** @return int<1, 24> */
    public function jamSelesai(): int
    {
        $nilai = $this->input('jam_selesai');

        return is_numeric($nilai) ? (int) $nilai : 21;
    }
}
