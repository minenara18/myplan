<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

/** Validasi permintaan ringkasan materi. */
final class SummarizeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /** @return array<string, array<int, string>> */
    public function rules(): array
    {
        return [
            'teks' => ['required', 'string', 'min:50', 'max:20000'],
        ];
    }

    public function teks(): string
    {
        return trim((string) $this->string('teks'));
    }
}
