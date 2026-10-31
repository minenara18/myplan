<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * @property string $name
 * @property string $email
 * @property string $password
 */
final class RegisterRequest extends FormRequest
{
    /** @return array<string, array<int, string>|string> */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:100'],
            'email' => ['required', 'string', 'email', 'max:255'],
            'password' => ['required', 'string', 'min:6'],
        ];
    }

    /**
     * Nama tidak wajib di aplikasi Flutter — isi bawaan bila kosong.
     *
     * @return array<string, mixed>
     */
    public function validatedPayload(): array
    {
        return [
            'name' => $this->input('name', 'Pengguna'),
            'email' => $this->input('email'),
            'password' => $this->input('password'),
        ];
    }
}
