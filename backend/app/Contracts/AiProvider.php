<?php

namespace App\Contracts;

use App\Exceptions\AiException;

/**
 * Kontrak penyedia LLM — tidak terikat pada penyedia tertentu.
 * Implementasi bawaan memakai endpoint kompatibel OpenAI,
 * tetapi penggantian penyedia cukup dengan mengubah Driver di container.
 */
interface AiProvider
{
    /**
     * Kirim satu percakapan (sistem + pengguna) dan kembalikan jawaban teks.
     *
     * @param  string  $sistem  instruksi sistem
     * @param  string  $pengguna  isi permintaan
     * @param  int|null  $timeoutDetik  mengesampingkan batas waktu konfigurasi
     *
     * @throws AiException ketika gagal (jaringan, waktu habis, respons tidak rapi)
     */
    public function selesaikan(string $sistem, string $pengguna, ?int $timeoutDetik = null): string;
}
